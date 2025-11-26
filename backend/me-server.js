import net from 'net';
import cron from 'node-cron';

const PORT = 21505;

let stoneDustCount = 0;
const server = net.createServer((socket) => {
  console.log('Client connected');
  // socket.write('update\n');

  // cron.schedule('*/10 * * * * *', () => {
  //   socket.write('update\n');
  // });

  socket.on('data', (data) => {
    console.log('Received data:', data.toString());
    try {
      let data_obj = JSON.parse(data);
      stoneDustCount = data_obj.size;
    } catch (e) {
      console.error('Invalid JSON received.');
      return;
    }
    console.log('Updated Stone Dust count:', stoneDustCount);
  });

  socket.on('end', () => {
    console.log('Client disconnected');
  });

  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

server.on('error', (err) => {
  console.error('Server error:', err);
});

server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});



import express from 'express';
const app = express()

app.get('/', (req, res) => {
  res.send(`Stone Dust: ${stoneDustCount}`);
})

app.listen(6720, () => {
  console.log(`listening on port ${6720}`)
})