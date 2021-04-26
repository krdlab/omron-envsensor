# OMRON 環境センサ (2JCIE-BL01) 検証

[ユーザーズマニュアル](https://omronfs.omron.com/ja_JP/ecb/products/pdf/CDSC-015.pdf)

## 利用パッケージ
- [@abandonware/noble](https://github.com/abandonware/noble)
- [futomi/node-omron-envsensor](https://github.com/futomi/node-omron-envsensor)

## メモ
- ADV setting (Characteristics UUID: 0x3042) を変更した場合は本体の再起動 (電池の抜き差し) が必要
- Beacon mode を変更すると Time information が 0 に初期化される
    - 初期値は 0x08 (Advertise format: C)
