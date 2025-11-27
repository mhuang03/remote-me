import net from 'net';
import cron from 'node-cron';

const PORT = 21505;

let stoneDustCount = 0;
let allItems = [];
const server = net.createServer((socket) => {
  console.log('Client connected');
  // socket.write('update\n');

  // cron.schedule('*/10 * * * * *', () => {
  //   socket.write('update\n');
  // });
  let buffer = [];
  socket.on('data', (data) => {
    let dataStr = data.toString();
    console.log('Received data:', dataStr);

    if (dataStr.length < 3) {
      console.error('Data too short.');
      return;
    }

    let dataType = dataStr.slice(0, 3);
    if (dataType === '100') {
      // Start of items data
      buffer = [];
      return;
    }

    if (dataType === '101') {
      // Chunk of items data
      let chunkData = dataStr.slice(3);
      try {
        let itemsChunk = JSON.parse(chunkData);
        buffer = buffer.concat(itemsChunk);
      } catch (e) {
        console.error('Invalid JSON chunk received.');
      }
      return;
    }

    if (dataType === '111') {
      // End of items data
      allItems = buffer;

      // Update stone dust count
      for (let item of allItems) {
        if (item.label === 'Stone Dust') {
          stoneDustCount = item.size;
          break;
        }
      }
      console.log('Stone Dust count after full update:', stoneDustCount);
      return;
    }
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
  // send basic html page with js that fetches /count every second and displays it
  res.send(`
    <html>
      <head>
        <title>Stone Dust Count</title>
      </head>
      <body>
        <h1>Stone Dust Count</h1>
        <div id="count">Loading...</div>
        <script>
          async function fetchCount() {
            const response = await fetch('/count');
            const data = await response.json();
            document.getElementById('count').innerText = data.stoneDustCount;
          }
          setInterval(fetchCount, 1000);
          fetchCount();
        </script>
      </body>
    </html>
  `);
});

app.get('/count', (req, res) => {
  res.json({ stoneDustCount });
});

app.listen(6720, () => {
  console.log(`listening on port ${6720}`)
});s