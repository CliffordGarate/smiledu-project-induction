const pg = require('pg');

const config ={
    database: 'bd_smiledu',    
    host:  'localhost',
    user:  'postgres',
    password:  '1234',  
}
const connection_bd = new pg.Pool(config);

module.exports = connection_bd;
;