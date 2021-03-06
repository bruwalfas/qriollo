
-- Este archivo es parte de Qriollo.

-- Qriollo is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Qriollo is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Qriollo.  If not, see <http://www.gnu.org/licenses/>.

module Backend.C_MM(memoryManager) where

memoryManager :: String
memoryManager = unlines [
 "/* Memory manager */",
 "",
 "#define Qr_MAX(X, Y)    ((X) > (Y) ? (X) : (Y))",
 "",
 "#define Qr_BLOCK_CAPACITY   8192",
 "#define Qr_MIN_THRESHOLD    3",
 "",
 "#define Qr_RECORD_TAG(X)      ((X) << 1)",
 "#define Qr_FLAG_REACHED       0x1",
 "#define Qr_RECORD_SIZE(X)     ((X) >> 1)",
 "",
 "typedef struct _QrBlock {",
 "    u64 idx; /* Next free position in the pool */",
 "    QrObj pool[Qr_BLOCK_CAPACITY];",
 "} QrBlock;",
 "",
 "typedef struct _QrMM {",
 "    QrBlock **blocks;  /* Resizable array of block pointers */",
 "    u64 capacity;      /* Number of available places for storing blocks */",
 "    u64 nblocks;       /* Number of used blocks */",
 "    u64 gc_threshold;  /* If nblocks > gc_threshold, we should gc */",
 "} QrMM;",
 "",
 "QrMM qr_mm;",
 "",
 "#define qr_mm_pool (qr_mm.blocks[qr_mm.nblocks - 1]->pool)",
 "#define qr_mm_idx  (qr_mm.blocks[qr_mm.nblocks - 1]->idx)",
 "",
 "#define Qr_MM_ALLOC(REC, SIZE) \\",
 "    if (qr_mm_idx + (SIZE) > Qr_BLOCK_CAPACITY) { \\",
 "        qr_mm_allocate_block((SIZE)); \\",
 "    } \\",
 "    REC = &qr_mm_pool[qr_mm_idx]; \\",
 "    qr_mm_idx += (SIZE);",
 "",
 "#define Qr_MM_SHOULD_GC() (qr_mm.capacity > qr_mm.gc_threshold)",
 "",
 "void qr_mm_init_block(QrBlock *block) {",
 "    block->idx = 0;",
 "    memset(block->pool, 0, sizeof(QrObj) * Qr_BLOCK_CAPACITY);",
 "}",
 "",
 "void *qr_malloc(size_t size) {",
 "    void *ptr = malloc(size);",
 "    if (ptr == NULL) {",
 "        fprintf(stderr, \"EN EL HORNO.\\n\");",
 "        fprintf(stderr, \"Sin memoria.\\n\");",
 "        exit(1);",
 "    }",
 "    return ptr;",
 "}",
 "",
 "void qr_mm_init() {",
 "    qr_mm.blocks = qr_malloc(sizeof(QrBlock *));",
 "    qr_mm.capacity = 1;",
 "    qr_mm.nblocks = 1;",
 "    qr_mm.gc_threshold = Qr_MIN_THRESHOLD;",
 "    qr_mm.blocks[0] = qr_malloc(sizeof(QrBlock));",
 "    qr_mm_init_block(qr_mm.blocks[0]);",
 "}",
 "",
 "void qr_mm_grow_blocks() {",
 "    QrBlock **new_blocks = " ++
 "qr_malloc(sizeof(QrBlock *) * 2 * qr_mm.capacity);",
 "    memcpy(new_blocks, qr_mm.blocks, sizeof(QrBlock *) * qr_mm.capacity);",
 "    qr_mm.capacity *= 2;",
 "    free(qr_mm.blocks);",
 "    qr_mm.blocks = new_blocks;",
 "}",
 "",
 "void qr_mm_allocate_block(u64 size) {",
 "    if (size > Qr_BLOCK_CAPACITY) {",
 "        fprintf(stderr, \"EN EL HORNO.\\n\");",
 "        fprintf(stderr, " ++
 "\"No se puede construir un objeto tan grande.\\n\");",
 "        exit(1);",
 "    }",
 "",
 "    /* Resize block array if needed */",
 "    if (qr_mm.nblocks >= qr_mm.capacity) {",
 "        qr_mm_grow_blocks();",
 "    }",
 "",
 "    /* Allocate a fresh block */",
 "    qr_mm.nblocks++;",
 "    qr_mm.blocks[qr_mm.nblocks - 1] = qr_malloc(sizeof(QrBlock));",
 "    qr_mm_init_block(qr_mm.blocks[qr_mm.nblocks - 1]);",
 "}",
 "",
 "void qr_mm_visit(QrObj *obj) {",
 "    if (Qr_OBJ_IMMEDIATE(*obj)) {",
 "        return;",
 "    }",
 "    QrObj *src = Qr_OBJ_AS_RECORD(*obj);",
 "",
 "    /* Copy the structure if it has not been reached */",
 "    if (!(src[0] & Qr_FLAG_REACHED)) {",
 "        u64 size = Qr_RECORD_SIZE(src[0]);",
 "",
 "        QrObj *dst;",
 "        Qr_MM_ALLOC(dst, size);",
 "        memcpy(dst, src, size * sizeof(QrObj));",
 "        ",
 "        src[0] = src[0] | Qr_FLAG_REACHED;",
 "        src[1] = Qr_RECORD_AS_OBJ(dst); /* Forwarding pointer */",
 "    }",
 "",
 "    /* Update the reference to the forwarding pointer */",
 "    *obj = src[1];",
 "}",
 "",
 "void qr_mm_free(QrMM *mm) {",
 "    u64 i;",
 "    for (i = 0; i < mm->nblocks; i++) {",
 "        free(mm->blocks[i]);",
 "    }",
 "    free(mm->blocks);",
 "}",
 "",
 "void qr_mm_end() {",
 "    qr_mm_free(&qr_mm);",
 "}",
 "",
 "void qr_mm_gc(u64 reachable_registers) {",
 "    /* Copy the static data of the current memory manager */",
 "    QrMM _old_mm;",
 "    memcpy(&_old_mm, &qr_mm, sizeof(QrMM)); ",
 "",
 "    /* Start over with a fresh memory manager */",
 "    qr_mm_init();",
 "",
 "    /* Visit the root set (all reachable registers) */",
 "    u64 i;",
 "    for (i = 0; i < Qr_NREGISTERS; i++) {",
 "        if (reachable_registers & (1 << i)) {",
 "            qr_mm_visit(&qr_reg[i]);",
 "        }",
 "    }",
 "",
 "    /* Visit all the objects in the new heap */",
 "    for (i = 0; i < qr_mm.nblocks; i++) {",
 "        u64 j;",
 "        for (j = 0; j < qr_mm.blocks[i]->idx; ) {",
 "            u64 k;",
 "            u64 size = Qr_RECORD_SIZE(qr_mm.blocks[i]->pool[j]);",
 "            for (k = 1; k < size; k++) {",
 "                qr_mm_visit(&qr_mm.blocks[i]->pool[j + k]);",
 "            }",
 "            j += size;",
 "        }",
 "    }",
 "",
 "    /* Free memory of the old memory manager */",
 "    qr_mm_free(&_old_mm);",
 "",
 "    /* Set a new GC threshold */",
 "    qr_mm.gc_threshold = Qr_MAX(2 * qr_mm.nblocks, Qr_MIN_THRESHOLD);",
 "}"
 ]
