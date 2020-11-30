
const movimientos_controller = {}
const pg = require('../database/database');

movimientos_controller.listar_movimientos = function (req, res) {
    const id_persona = req.params.id_persona;
    console.log("id_persona: ", id_persona)
    const query = "select * from listarMovimientosEstudiante($1);";
  
    pg.query(query,[id_persona],  (err, movimientos) => {
      if (!err) {
        res.status(200).json({ status: 'Success', movimientos: movimientos.rows, code: 200 })
      } else {
          console.log("error: ", err)
        res.status(400).json({ status: 'Error', error: err, code: 400 });
      }
    })
  }


  movimientos_controller.actualizar_estado = function (req, res) {
    const body = req.body;
    const id_movimiento = body.id_movimiento;
    const estado = body.estado;
    const query = "select actualizarEstadoMovimiento($1, $2);";
  
    pg.query(query,[id_movimiento, estado],  (err, respuesta) => {
      if (!err) {
        res.status(200).json({ status: 'Success', message: 'Movimiento actualizado éxitosamente.', code: 200 })
      } else {
          console.log("error: ", err)
        res.status(400).json({ status: 'Error', error: err, code: 400 });
      }
    })
  }


module.exports = movimientos_controller;