##第１世代fpu

- 説明とか  
パイプラインは全く考慮してないです。  
とりあえず僕はmake_randam_data.cをコンパイルして、テキトーに

```  
./make_random_data (作るデータの個数) (0->add,1->mul)
```
ってするとinput.datとanswer.datってのができるので、workディレクトリに入れて、テストベンチ(top_tb.vhdかtop_tb_mul.vhd)を走らせて、出てきたデータと比べてました。

今は非正規化数とかの扱いは雑なので、なにかあったら言ってください。
