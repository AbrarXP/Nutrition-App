import { DataTypes, Sequelize } from "sequelize";
import db from "../config/database.js";

// Membuat tabel "user"
const User = db.define(
  "users", // Nama Tabe
  {
    userID : {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    username: Sequelize.TEXT,
    password: Sequelize.TEXT,
    shift: DataTypes.INTEGER,
    email: Sequelize.TEXT,
    bb: DataTypes.DOUBLE,
    tb: DataTypes.DOUBLE,
    usia: DataTypes.INTEGER,
    jenis_kelamin:Sequelize.TEXT
  },
  {
    timestamps: false 
  }
);

export default User;