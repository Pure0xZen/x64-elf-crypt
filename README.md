# x64-elf-crypt

An educational x86-64 assembly encryptor and decryptor built natively for Linux ELF64 binaries.

---

## 📖 Description

A simple command-line tool written in pure x86-64 Assembly (NASM) that encrypts and decrypts messages using a custom XOR-based cipher with a random nonce and key derivation. It uses the `rdseed` instruction for randomness and outputs the result as hex.

> **⚠️ Warning:** This is a toy cipher for learning purposes only. It is **NOT** cryptographically secure. Do not use it to protect sensitive data.

---

## ✨ Features

* Interactive menu: Encrypt or Decrypt.
* Random nonce generated via `rdseed`.
* Custom XOR cipher with key derivation.
* Hex output for encrypted data.
* Written entirely in x86-64 Assembly (NASM syntax).
* Targets Linux ELF64.

---

## 🛠️ Requirements

* NASM assembler
* GNU `ld` linker
* Linux x86-64 system
* CPU with `rdseed` support (Intel Broadwell+ or AMD Zen+)

---

## 🚀 Build & Compilation

```bash
nasm -f elf64 crypt.asm -o crypt.o
ld crypt.o -o crypt
```

---

## 💡 Usage

Run the compiled binary directly from your terminal:

```bash
./crypt
```

Follow the interactive prompts:

* Choose `1` to encrypt a plaintext message or `2` to decrypt.
* Enter your message (when decrypting, paste the formatted hex string).
* View the generated result.

---

## 🐧 Running on WSL

This program can also be built and run under Windows Subsystem for Linux (WSL).

* Ensure you are using WSL2 with an x86-64 Linux distribution (such as Ubuntu or Fedora).
* Verify that your virtualized or physical CPU passes through `rdseed` support.

---

## 🔮 Future Improvements

* Additional block-scattering variations.
* Further low-level optimizations.

---

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
