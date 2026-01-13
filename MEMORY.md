# rsmpi + MPItrampoline パッチについて

## パッチが必要な理由

### 背景: MPItrampoline のアーキテクチャ

MPItrampoline は MPI のフォワーディングレイヤーで、実際の MPI 実装（OpenMPI, MPICH など）を**実行時**に動的にロードする。これにより、コンパイル時に特定の MPI 実装に依存せず、実行時に任意の MPI ライブラリを選択できる。

### 問題点

標準的な MPI 実装では、`MPI_COMM_WORLD`、`MPI_INT`、`MPI_SUCCESS` などの定数はコンパイル時に決定される（多くの場合マクロとして定義）。

```c
// 通常の MPI 実装（例: OpenMPI）
#define MPI_COMM_WORLD ((MPI_Comm)0x44000000)
```

しかし MPItrampoline では、これらの値は**実行時**にロードされた MPI 実装から取得されるため、コンパイル時には不明。

rsmpi の元のコードは `const` 修飾子付きでこれらの定数を宣言している:

```c
const MPI_Comm RSMPI_COMM_WORLD = MPI_COMM_WORLD;  // コンパイル時に初期化
```

これは MPItrampoline では動作しない。MPItrampoline の `MPI_COMM_WORLD` は実行時まで有効な値を持たないため。

### 解決策

パッチは以下の変更を行う:

1. **`const` 修飾子の削除**: 定数をミュータブルなグローバル変数に変更
2. **コンストラクタ関数の追加**: `__attribute__((constructor))` を使用して、`main()` 実行前に定数を初期化

```c
// パッチ後
MPI_Comm RSMPI_COMM_WORLD;  // 宣言のみ

__attribute__((constructor))
static void rsmpi_init_constants(void) {
    RSMPI_COMM_WORLD = MPI_COMM_WORLD;  // 実行時に初期化
}
```

### パッチ対象ファイル

- `mpi-sys/src/rsmpi.c` - C 定数の初期化方法を変更
- `mpi-sys/src/rsmpi.h` - ヘッダーから `const` を削除
- `src/collective.rs` - `MPI_SUCCESS` を実行時に取得
- `src/request.rs` - `MPI_UNDEFINED` を実行時に取得

### 参考

- [MPItrampoline GitHub](https://github.com/eschnett/MPItrampoline)
- [rsmpi GitHub](https://github.com/rsmpi/rsmpi)
