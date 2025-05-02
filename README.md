1. **Memory Mapping**

   * **Input** – `mmap` 500 MB anonymous, read‑only buffer for the full RGBA stream.
   * **Output** – `ftruncate` grows `stdout` to 125 MB, then `mmap` maps it.
    
2. **Shuffle Mask**
   A 32‑byte constant is loaded into **YMM15**. With `vpshufb` it keeps every 3rd byte

3. **Main Loop**

   | Step | Instruction              | Purpose                                |
   | ---- | ------------------------ | -------------------------------------- |
   | a    | `prefetcht0`             | Bring next input page into cache.      |
   | b    | `vmovdqa`                | Load 32 B (8 px) of RGBA.              |
   | c    | `vpshufb`                | Extract 8 blue bytes.                  |
   | d    | `vextracti128` + `vmovd` | Split lanes & move to GPRs.            |
   | e    | `shl`/`or`               | Pack the 8 bytes into one 64‑bit word. |
   | f    | `movnti`                 | Stream‑store to output (cache‑bypass). |

4. **Exit**

   * `vzeroupper` avoid transition penalties
   * `syscall 60` exits.

