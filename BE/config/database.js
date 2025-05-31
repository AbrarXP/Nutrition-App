import { Sequelize } from "sequelize";

// Nyambungin db ke BE
const db = new Sequelize("gizi_db", "root", "", {
  host: "localhost",
  dialect: "mysql",
  timezone: '+07:00',
});

export default db;