import db from '../config/database.js';
import { DataTypes } from 'sequelize';

const Makanan = db.define('makanan', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  userID: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  nama_makanan: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  waktu_konsumsi: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  }
}, {
  timestamps: false
});

export default Makanan