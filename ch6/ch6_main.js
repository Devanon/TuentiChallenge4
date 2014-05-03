#!/usr/bin/env node

var net = require('net');
var util = require('util');
var crypto = require('crypto');

var options = {
    'port': 6969,
    'host': '54.83.207.90',
}

var input_keyphrase;
process.stdin.once('data', function(data) {
    input_keyphrase = data.toString().trim();
    state++;
});

var dh, secret, state = 0;

var socket = net.connect(options);

socket.on('data', function(data) {

    data = data.toString().trim().split('|');

    if (state == 1 && data[0] == 'CLIENT->SERVER:hello?') {
        socket.write('hello?');
        state++;

    } else if (state == 2 && data[0] == 'SERVER->CLIENT:hello!') {
        socket.write('hello!');
        state++;
    
    } else if (state == 3 && data[0] == 'CLIENT->SERVER:key') {
        dh = crypto.createDiffieHellman(256);
        dh.generateKeys();
        socket.write(util.format('key|%s|%s\n', dh.getPrime('hex'), dh.getPublicKey('hex')));
        state++;
    
    } else if (state == 4 && data[0] == 'SERVER->CLIENT:key') {
        socket.write('key|' + data[1]);
        secret = dh.computeSecret(data[1], 'hex');
        state++;
    
    } else if (state == 5 && data[0] == 'CLIENT->SERVER:keyphrase') {
        var cipher = crypto.createCipheriv('aes-256-ecb', secret, '');
        var keyphrase = cipher.update(input_keyphrase, 'utf8', 'hex') + cipher.final('hex');
        socket.write(util.format('keyphrase|%s\n', keyphrase));
        state++;
    
    } else if (state == 6 && data[0] == 'SERVER->CLIENT:result') {
        var decipher = crypto.createDecipheriv('aes-256-ecb', secret, '');
        var message = decipher.update(data[1], 'hex', 'utf8') + decipher.final('utf8');
        console.log(message);
        socket.end();
    }
});
