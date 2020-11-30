//express
const express = require('express');

 //importar parser de JSON
const bodyParser = require('body-parser');

//para registrar las peticiones que llegan
const morgan = require('morgan');

//metodo path se encarga de unir directorios
const path = require('path');

const app = express();

const server = require('http').createServer(app);

//Cors
const cors = require('cors');

require('./src/database/database');

app.set('port', process.env.APP_PORT || 3012);

// Configuración
//-----Middlewares---------
app.use(morgan('dev'));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

//--------Cors--------
app.use(cors())

//--------Rutas--------
app.use('/api', require('./src/routes'));

//Para Aceptar imagenes en la carpeta public
app.use('/public', express.static(path.join(__dirname, './src/public/uploads')));

//Escuchando el Servidor
server.on('listening',function(){
    console.log('Servidor en el puerto', app.get('port'));
});

server.listen(app.get('port'));