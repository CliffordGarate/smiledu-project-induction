const express = require('express');
const router = express.Router();
const personas_controller = require('../controllers/personas.controller');
const multipart = require('connect-multiparty');
const multipartMiddleware = multipart({uploadDir:'./src/public/uploads/personas'});
// GET
router.get('/list',personas_controller.listar_estudiantes);
router.post('/register', multipartMiddleware, personas_controller.registrar_estudiantes);
router.get('/list-grados',personas_controller.listar_grados);

module.exports = router ;