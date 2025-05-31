import Makanan from '../models/makananModel.js';
import User from "../models/userModel.js";

import { Op } from 'sequelize';

export const getAllMakanan = async (req, res) => {
  try {
    const makanan = await Makanan.findAll();
    res.json(makanan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const getMakananByUserAndDate = async (req, res) => {
  const { userID } = req.params;
  const { tanggal } = req.query;
  try {

    const startDate = new Date(`${tanggal}T00:00:00+07:00`);
    const endDate = new Date(`${tanggal}T23:59:59+07:00`);

    const makanan = await Makanan.findAll({
      where: {
        userID: userID,
        waktu_konsumsi: {
          [Op.gte]: startDate,
          [Op.lt]: endDate,
        },
      },
    });
    res.json(makanan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
/*
Op.gte artinya "greater than or equal" (lebih besar sama dengan) tanggal yang dimulai dari jam 00:00:00 pada hari tersebut.
Op.lt artinya "less than" (kurang dari) tanggal di jam 23:59:59 pada hari yang sama.
Jadi, dia ambil semua data makanan yang dikonsumsi user itu pada tanggal yang dipilih, dari awal sampai akhir hari itu. 
*/

export const createMakanan = async (req, res) => {
  const { userID, nama_makanan, waktu_konsumsi } = req.body;
  try {

    const user = await User.findByPk(userID);
    if (!user) return res.status(404).json({ msg: "User tidak ditemukan" });

    const makanan = await Makanan.create({ 
        userID: userID, 
        nama_makanan: nama_makanan, 
        waktu_konsumsi: new Date()
    });

    res.json({ msg: 'Makanan berhasil ditambahkan', makanan });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const updateMakanan = async (req, res) => {
  const { id } = req.params;
  const { nama_makanan, waktu_konsumsi } = req.body;
  try {
    await Makanan.update({ 
        nama_makanan, 
        waktu_konsumsi 
    }, { where: { id } });

    res.json({ msg: 'Makanan berhasil diupdate' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const deleteMakanan = async (req, res) => {
  const { id } = req.params;
  try {
    await Makanan.destroy({ where: { id } });
    res.json({ msg: 'Makanan berhasil dihapus' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};