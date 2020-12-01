const personas_controller = {}
const pg = require('../database/database');

// listar estudiantes

personas_controller.listar_estudiantes = function (req, res) {
  const query = "select * from listarEstudiantes();";

  pg.query(query, (err, estudiantes) => {
    if (!err) {
      res.status(200).json({ status: 'Success', estudiantes: estudiantes.rows, code: 200 })
    } else {
      res.status(400).json({ status: 'Error', error: err, code: 400 });
    }
  })
}

personas_controller.registrar_estudiantes = function (req, res) {
  const body = req.body;
  const nombre = body.nombre;
  const ape_pat = body.ape_pat;
  const ape_mat = body.ape_mat;
  const fecha_nac = body.fecha_nac;
  const id_grado = body.id_grado;
  const nivel = body.nivel;
  const query = "select registrarEstudiante($1,$2,$3,$4,$5,$6);";
  const query2 = "select registerMovimiento($1,$2);"

  const foto = req.files.foto;
  var nombre_foto = (foto.path).split('/')[4];
  var extension_foto = (foto.type).split('/')[1];

  if (extension_foto == 'jpg' || extension_foto == 'png' || extension_foto == 'jpeg') {
    pg.query(query, [nombre, ape_pat, ape_mat, fecha_nac, nombre_foto, id_grado], (err, id_estudiante) => {
      if (!err) {
        console.log("id_estudiante: ", id_estudiante.rows[0].registrarestudiante)
        console.log("nivel: ", nivel)
        pg.query(query2, [id_estudiante.rows[0].registrarestudiante, nivel],(err2, respuesta)=>{
          if(!err2){
            console.log("respuesta de mov: ", respuesta)
            res.status(200).json({ status: 'Success', id_estudiante: id_estudiante.rows[0].registrarestudiante, code: 200 })
          }else{
            console.log("error2: ", err2)
            res.status(400).json({ status: 'Error en registro de movimientos', error: err2, code: 400 });
          }
        })
      } else {
        console.log("error1: ", err)
        res.status(400).json({ status: 'Error en registro de estudiante', error: err, code: 400 });
      }
    })
  } else {
    res.status(400).send({ status: 'Error', message: 'Tipo de imagen incorrecta', code: 400 });
  }
}


personas_controller.listar_grados = function (req, res) {
  const query = "select * from grado;";

  pg.query(query, (err, grados) => {
    if (!err) {
      res.status(200).json({ status: 'Success', grados: grados.rows, code: 200 })
    } else {
      res.status(400).json({ status: 'Error', error: err, code: 400 });
    }
  })
}




module.exports = personas_controller;