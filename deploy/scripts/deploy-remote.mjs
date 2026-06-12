import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
import { Client } from 'ssh2';

const root = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const configPath = join(root, 'deploy', 'config.env');
const keyPath = join(root, 'deploy', '.vultr-key');

function loadConfig() {
  if (!existsSync(configPath)) throw new Error(`Missing ${configPath}`);
  const cfg = {};
  const text = readFileSync(configPath, 'utf8').replace(/^\uFEFF/, '');
  for (const line of text.split(/\r?\n/)) {
    const m = line.match(/^\s*([^#][^=]+)=(.*)$/);
    if (m) cfg[m[1].trim()] = m[2].trim();
  }
  return cfg;
}

function exec(conn, cmd) {
  return new Promise((resolve, reject) => {
    conn.exec(cmd, (err, stream) => {
      if (err) return reject(err);
      let out = '';
      let errOut = '';
      stream.on('data', (d) => { out += d; process.stdout.write(d); });
      stream.stderr.on('data', (d) => { errOut += d; process.stderr.write(d); });
      stream.on('close', (code) => {
        if (code === 0) resolve(out);
        else reject(new Error(`Command failed (${code}): ${cmd}\n${errOut}`));
      });
    });
  });
}

function upload(conn, localPath, remotePath) {
  return new Promise((resolve, reject) => {
    conn.sftp((err, sftp) => {
      if (err) return reject(err);
      sftp.fastPut(localPath, remotePath, (e) => (e ? reject(e) : resolve()));
    });
  });
}

async function main() {
  const cfg = loadConfig();
  const host = cfg.VULTR_HOST;
  const user = cfg.SSH_USER || 'root';
  const port = Number(cfg.SSH_PORT || 22);
  const remote = cfg.REMOTE_PATH || '/var/www/weevent';
  const domain = cfg.DOMAIN || 'we-events.co.nz';
  const email = cfg.SSL_EMAIL || `admin@${domain}`;

  if (!host || host === 'YOUR_SERVER_IP') throw new Error('Set VULTR_HOST in deploy/config.env');
  if (!existsSync(keyPath)) throw new Error('Missing deploy/.vultr-key');

  console.log('==> Building site...');
  execSync('npm run build', { cwd: root, stdio: 'inherit' });

  const archive = join(root, 'deploy', 'release.tar.gz');
  console.log('==> Packaging...');
  execSync(`tar -czf "${archive}" -C dist .`, { cwd: root, stdio: 'inherit', shell: true });

  const privateKey = readFileSync(keyPath);
  const conn = new Client();

  await new Promise((resolve, reject) => {
    conn
      .on('ready', resolve)
      .on('error', reject)
      .connect({ host, port, username: user, privateKey });
  });

  const previewPort = cfg.PREVIEW_PORT || '8888';

  console.log('==> Uploading site archive...');
  await upload(conn, archive, '/tmp/weevent-release.tar.gz');

  console.log(`==> Installing nginx preview on port ${previewPort}...`);
  const setupSh = readFileSync(join(root, 'deploy', 'scripts', 'install-port.sh'), 'utf8');
  await exec(conn, `cat > /root/install-port.sh << 'SETUP_EOF'\n${setupSh}\nSETUP_EOF`);
  await exec(conn, `bash /root/install-port.sh ${previewPort} /tmp/weevent-release.tar.gz`);

  conn.end();
  console.log(`\nDone! http://${host}:${previewPort}/en/`);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
