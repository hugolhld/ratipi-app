# RATIPI APP

## Getting Started

### WebSocket Server
 - For the moment you can use `wss://ws.hugolhld.xyz:3000`
 - Create a web sockets server or go in foler web socket at root of project
 - If you want start WS from project
 - Run `npm i` in `/WS-server`
 - Run `node index.js`
 - That return a localhost ip
 
 If you want have a public domain, you can install *localtunnel* with `npm install -g localtunnel`
 - After just run `lt --port 8080` for expose your localhost

### Run App
 - Copy `.env.example` to `.env`
 - Paste your `ws://` with your server ip of web sockets
 - You need *Flutter SDK* installed on your machine
 - At root of project
 - Run `flutter pub get`
 - You have now all dependency
 - Check you have iOS or Android Simulator installed
 - Start an emulator
 - Run `flutter run`
 - You should have app on emulator ! :tada:
