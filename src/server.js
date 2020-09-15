/* eslint no-use-before-define: 0 */
const path = require('path');
const fs = require('fs');
const net = require('net');
const { forward } = require('@quanxiaoxiao/net');
const ss = require('./ss');
const config = require('./config');

const server = net.createServer();

server.on('connection', (socket) => {
  const handleTimeout = () => {
    if (!socket.destroyed) {
      socket.destroy();
    }
  };
  const handleError = () => {
    socket.off('timeout', handleTimeout);
  };
  socket.once('error', handleError);
  socket.once('data', (chunk) => {
    socket.pause();
    try {
      const { incoming, outgoing } = ss.handler();
      const options = ss.getOptions(outgoing(chunk));
      if (!socket.writable) {
        return;
      }
      forward(socket, {
        ...options,
        incoming,
        outgoing,
      });
      socket.once('timeout', handleTimeout);
      socket.setTimeout(1000 * 30);
      socket.resume();
      socket.off('error', handleError);
    } catch (error) {
      socket.destroy();
    }
  });
});

server.listen(config.port, () => {
  console.log(`listen at port ${config.port}`);
});

process.on('uncaughtException', (error) => {
  console.error(error);
  fs.writeFileSync(path.resolve(__dirname, '..', `${Date.now()}-error.log`), error.message);
  const killTimer = setTimeout(() => {
    process.exit(1);
  }, 3000);
  killTimer.unref();
});

module.exports = server;
