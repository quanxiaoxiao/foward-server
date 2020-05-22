const crypto = require('crypto');
const { struct } = require('@quanxiaoxiao/binary');
const config = require('./config');

const pre = crypto.createHash('md5');
pre.update(Buffer.from(config.ss.key));
const preDigest = pre.digest();

const post = crypto.createHash('md5');
post.update(Buffer.concat([
  preDigest,
  Buffer.from(config.ss.key),
]));
const postDigest = post.digest();

const privateKey = Buffer.concat([
  preDigest,
  postDigest,
]);

const getOptions = (chunk) => {
  const result = struct(chunk)
    .buf('type', 2, (d) => d.equals(Buffer.from([0x00, 0x07])))
    .int8('hostlength', (d) => d > 4)
    .buf('hostname', (d) => d.hostlength)
    .int16('port')();
  return {
    hostname: result.hostname.toString(),
    port: result.port,
    bufList: result.data ? [result.data] : [],
  };
};

const handler = () => {
  let cipher;
  let decipher;
  const outgoing = (chunk) => {
    if (!decipher) {
      decipher = crypto.createDecipheriv('rc4', privateKey, '');
      return decipher.update(chunk);
    }
    return decipher.update(chunk);
  };
  const incoming = (chunk) => {
    if (!cipher) {
      cipher = crypto.createCipheriv('rc4', privateKey, '');
      return cipher.update(chunk);
    }
    return cipher.update(chunk);
  };

  return {
    incoming,
    outgoing,
  };
};

exports.handler = handler;
exports.getOptions = getOptions;
