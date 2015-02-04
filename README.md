preentrance-task
================

## 疑問点
### Swift言語仕様
- IBOutletやdelegateをオプショナル型じゃないようにする方法はあるのか？

### 実装方針
- 判定を個々のマスに散らしたのはスケーラビリティ的にどうなのか？？（Observerパターン）  
→処理を各マスに散らすべきか、バトルフィールドに集結させるべきか
- Squareクラス内のファイルにいろいろ書きすぎ。
- Stateパターンの部分だけ、関数型（？）っぽい感じになるのが若干違和感。（今回の場合は、インナークラスから外部のメンバ変数へのアクセスの仕方さえ知れればよい？？）
- GameMangerがあんまりGameをManageできてない
- BombStateのSqaureについて。Stateを見え方として使い、実際爆弾かどうかをisBombに持たせたのはバグの温床か？？（実際バグった）  
→ ユーザーからの見え方と、実際の爆弾からの見え方という、２つの視点がある以上やむを得ない？？
