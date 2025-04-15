# PVDF Signature Verification System

A low-cost, low-power signature verification system using a PVDF piezoelectric sensor.  
This project captures physical handwriting patterns — including pressure and vibration —  
and classifies them using machine learning to detect forged signatures.

> 🚧 This project is currently under active development. More features, refinements, and hardware improvements will be added progressively.

---

## 📌 Project Overview

- 🖊️ **Hardware**: PVDF film sensor captures pressure & vibration during signature
- 🔧 **Analog Front-End**: Passive filtering, DC biasing, and voltage scaling for ADC input
- 💻 **FPGA/MCU Interface**: Digitizes sensor data using internal ADC (0~1V input range)
- 🤖 **Machine Learning**: Classifies real vs forged signatures based on extracted features
- 📊 **Feature Engineering**: Uses duration, slope, ZCR, envelope, and peak count
- 🛡️ **Security Application**: Can be embedded in smart pens, legal authentication, or banking terminals

---

## 🧩 System Architecture


---

## 🛠️ Hardware (Analog Front-End)

| Block | Function |
|-------|----------|
| High impedance input + discharge resistor | Preserves signal without rapid leakage |
| AC coupling capacitor | Blocks sensor's internal DC bias |
| Low-pass filter | Removes high-frequency noise |
| Notch filter (60Hz Twin-T) | Removes power line noise |
| DC bias generation | Centers signal around 0.5V (for ADC) |
| Passive attenuator | Scales voltage to fit 0~1V ADC range |
| Zener clamping | Protects ADC from voltage spikes |

---

## 💾 Data Collection

- Sampling rate: 1~5 kHz
- Digitized pressure signal saved as `.csv` per signature
- Real and forged signature sets stored in separate folders

---

## 🧠 Machine Learning (Python)

### Extracted Features:
- **Duration**: How long pressure remains above threshold
- **Slope**: Average rising/falling rate of signal
- **Zero Crossing Rate**: Number of 0-crossings in waveform
- **Envelope (rectified + LPF)**: Shape of vibration
- **Peak Count**: Signal complexity

### Classifier:
- **SVM (Support Vector Machine)** with RBF kernel  
- Future versions may include: KNN, RandomForest, LSTM

### Tools:
- `scikit-learn`, `numpy`, `pandas`, `matplotlib`

---

## 📁 Directory Structure (WIP)


---

## 🔮 Roadmap

- [x] Analog front-end complete
- [x] Basic data acquisition
- [x] Python ML pipeline
- [ ] Real-time classification on embedded system
- [ ] Add Bluetooth module for wireless signature transfer
- [ ] Web dashboard for model feedback

---

## Progress Pictures

![chargeamp](https://github.com/user-attachments/assets/d0ffb33e-5f50-46db-bdd3-1be8e984971b)
![1](https://github.com/user-attachments/assets/4f2190f4-081e-4b7c-a702-3df4801dd7f6)
![ancircuit](https://github.com/user-attachments/assets/2c3f8b6a-bc57-4580-9543-1d79e5c0f861)
![proto1](https://github.com/user-attachments/assets/4bc72636-2e6d-44a3-9007-d82d38b59a8a)
![scope_36_filtered](https://github.com/user-attachments/assets/fa8cd858-499f-4bb3-94f9-8c9c343a780f)
![5f](https://github.com/user-attachments/assets/8888ed50-489a-4fe3-ba96-16f9ffd5e57f)




## 🙌 Contribution

This project is in its early stages. Contributions, ideas, or forks are very welcome!  
Feel free to create issues or pull requests as needed.

---
