const express = require('express');
const router = express.Router();
const movimientos_controller = require('../controllers/movimientos.controller');

// GET
router.get('/list/:id_persona',movimientos_controller.listar_movimientos);
router.put('/actualizar_estado',movimientos_controller.actualizar_estado);

module.exports = router ;