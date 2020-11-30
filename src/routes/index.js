const express = require('express');

const Router = express.Router();

Router.use('/personas',require('./personas.routes'))
Router.use('/movimientos',require('./movimientos.routes'))

module.exports = Router;
