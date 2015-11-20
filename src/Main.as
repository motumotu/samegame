package
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.text.*;
    import flash.display.*;
	import flash.net.*;
 
    [SWF(width="600",height="300",backgroundColor="0xffffff",frameRate="60")]
    public class Main extends Sprite
    {

        [Embed(source = "./block1.png")] private var IMAGE_1:Class;
		[Embed(source = "./block2.png")] private var IMAGE_2:Class;
		[Embed(source = "./block3.png")] private var IMAGE_3:Class;
		[Embed(source = "./block4.png")] private var IMAGE_4:Class;
		[Embed(source = "./submit.gif")] private var IMAGE_SUBMIT:Class;
		[Embed(source = "./reset.gif")] private var IMAGE_RESET:Class;
		
		//---- 定数
		public static const WIDTH:int = 20;
		public static const HEIGHT:int = 20;
		public static const WIDTH_SIZE:int = 20;
		public static const HEIGHT_SIZE:int = 15;
		public static const BLOCK_KIND:int = 4;
		public static const QUANTITY_NUM:int = 30;
		
		//---- インスタンス変数
		private var board:Array;  // 盤面情報
		private var score:int = 0;    // スコア
		private var score_num:int = 0; // スコア比率
		private var quantity:int = QUANTITY_NUM; // 残り回数
		private var score_flame:TextField;
		private var score_label:TextField;
		private var input_box:TextField;
		private var input_label:TextField;
		private var quantity_flame:TextField;
		private var quantity_label:TextField;
		// 通信用
		private var php_file:String = "ranking.php";
		private var loader:URLLoader;
		
		//---- 画像ハンドル
		private var canvas:BitmapData;
		private var image1:BitmapData;
		private var image2:BitmapData;
		private var image3:BitmapData;
		private var image4:BitmapData;
		private var image_submit:BitmapData;
		private var image_reset:BitmapData;

		//---- コンストラクタ
        public function Main()
        {
			//---- インスタンス生成
			// スコアラベル
			score_label = new TextField();
			score_label.defaultTextFormat = new TextFormat("ＭＳ ゴシック", 24, 0x000000);
			score_label.x = 410;
			score_label.y = 20;
			score_label.text = "スコア";
			addChild(score_label);
			// スコア
			score_flame = new TextField();
			score_flame.defaultTextFormat = new TextFormat("ＭＳ ゴシック", 24, 0x000000);
			score_flame.x = 410;
			score_flame.y = 50;
			score_flame.text = score.toString();
			addChild(score_flame);
			// 残り回数
			quantity_label = new TextField();
			quantity_label.defaultTextFormat = new TextFormat("ＭＳ ゴシック", 24, 0x000000);
			quantity_label.x = 410;
			quantity_label.y = 80;
			quantity_label.text = "残り回数";
			addChild(quantity_label);
			// 残り回数表示
			quantity_flame = new TextField();
			quantity_flame.defaultTextFormat = new TextFormat("ＭＳ ゴシック", 24, 0x000000);
			quantity_flame.x = 410;
			quantity_flame.y = 110;
			quantity_flame.text = quantity.toString();
			addChild(quantity_flame);
			// 名前入力ラベル
			input_label = new TextField();
			input_label.defaultTextFormat = new TextFormat("ＭＳ ゴシック", 24, 0x000000);
			input_label.x = 410;
			input_label.y = 140;
			input_label.text = "名前";
			addChild(input_label);
			// 名前入力欄
			input_box = new TextField();
			input_box.defaultTextFormat = new TextFormat("ＭＳ ゴシック", 24, 0x000000);
			input_box.x = 410;
			input_box.y = 170;
			input_box.type = TextFieldType.INPUT;
			input_box.border = true;
			input_box.width = 180;
			input_box.height = 30;
			addChild(input_box);
			// 盤面
			board = new Array(HEIGHT);
			for ( var i:int = 0; i < HEIGHT; i++ ) {
				board[i] = new Array(WIDTH);
			}
			//---- 初期化
			gameInit();
			
			//---- 画像読み込み
			loadImage();
			
			//---- キャンバス
			canvas = new BitmapData(600, 450, true, 0x0);
			var bitmap:Bitmap = new Bitmap(canvas);
			addChild(bitmap);
			
			//---- 通信用
			
			
			//---- イベント処理
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onMouseDown);
        }
		
		//---- 毎フレーム
		public function onEnterFrame(event:Event):void 
		{
			render();
		}
		
		//---- 画像読み込み
		public function loadImage():void
		{
			image1 = Bitmap(new IMAGE_1()).bitmapData;
			image2 = Bitmap(new IMAGE_2()).bitmapData;
			image3 = Bitmap(new IMAGE_3()).bitmapData;
			image4 = Bitmap(new IMAGE_4()).bitmapData;
			image_reset = Bitmap(new IMAGE_RESET()).bitmapData;
			image_submit = Bitmap(new IMAGE_SUBMIT()).bitmapData;
		}
		
		//---- ゲーム初期化
		public function gameInit():void
		{
			score = 0;
			score_num = 0;
			quantity = QUANTITY_NUM;
			boardInit();
		}
		
		//---- 盤面初期化
		public function boardInit():void
		{
			for ( var i:int = 0; i < HEIGHT; i++ ) {
				for ( var j:int = 0; j < WIDTH; j++ ) {
					board[i][j] = Math.round(Math.random() * (BLOCK_KIND-1)) + 1;
				}
			}
		}
		
		//---- 描画
		public function render():void
		{
			//---- 画面クリア
			canvas.fillRect(canvas.rect, 0x0);
			//---- 盤面描画
			for ( var i:int = 0; i < HEIGHT; i++ ) {
				for ( var j:int = 0; j < WIDTH; j++ ) {
					if ( board[i][j] > 0 && board[i][j] <= BLOCK_KIND ) {
						switch (board[i][j]) {
						case 1:
							canvas.copyPixels(image1, image1.rect, new Point(WIDTH_SIZE * j, HEIGHT_SIZE * i));
							break;
						case 2:
							canvas.copyPixels(image2, image2.rect, new Point(WIDTH_SIZE * j, HEIGHT_SIZE * i));
							break;
						case 3:
							canvas.copyPixels(image3, image3.rect, new Point(WIDTH_SIZE * j, HEIGHT_SIZE * i));
							break;
						case 4:
							canvas.copyPixels(image4, image4.rect, new Point(WIDTH_SIZE * j, HEIGHT_SIZE * i));
							break;
						}
					}
				}
			}
			//---- ボタン描画
			canvas.copyPixels(image_submit, image_submit.rect, new Point(530, 210));
			canvas.copyPixels(image_reset, image_reset.rect, new Point(410, 260));
		}
		
		//---- クリック処理
		public function onMouseDown(event:MouseEvent):void
		{
			//--- 盤面クリック
			if ( mouseX >= 0 && mouseX < 400 && mouseY >= 0 && mouseY < 300 && quantity > 0 ) {
				var select_x:int = Math.floor(mouseX / WIDTH_SIZE);
				var select_y:int = Math.floor(mouseY / HEIGHT_SIZE);
				//trace(select_x + " " + select_y);
				deleteBlock(select_x, select_y);
				// 残り回数
				quantity--;
			}
			//---- リセット410, 260
			if ( mouseX >= 410 && mouseX <= 470 && mouseY >= 260 && mouseY <= 285 ) {
				gameInit();
			}
			//---- 送信ボタン530, 210
			if ( mouseX >= 530 && mouseX <= 590 && mouseY >= 210 && mouseY <= 235 ) {
				postScore("noname");
			}
			
			// 更新
			score_flame.text = score.toString();
			quantity_flame.text = quantity.toString();
		}
		
		//---- ブロックを消す
		public function deleteBlock(x:int, y:int):void
		{
			//---- ブロック消せるか判定します
			var flag:Boolean = false;
			for ( var dx:int = -1; dx <= 1; dx++ ) {
				for ( var dy:int = -1; dy <= 1; dy++ ) {
					if ( (dx == 0 && dy == 0) || (dx != 0 && dy != 0) ) { continue; }
					if ( x + dx >= WIDTH || x + dx < 0 || y + dy >= HEIGHT || y + dy < 0 ) { continue; }
					if ( board[y][x] == board[y + dy][x + dx] ) { flag = true; }
				}
			}
			// 消せないとき
			if ( flag == false ) {
				// 減点
				score -= 100;
				if ( score < 0 ) { score = 0; }
				return;
			}
			
			//---- 消します
			score_num = 0;
			deleteBlockDir(x, y);
			score += (score_num * 10) * ((score_num + 10) / 10);
			
			//---- ブロックを落とします
			fallBlock();
			
			//---- 新しいブロックを追加
			addNewBlock();
		}
		
		//---- 周辺のブロックを消します
		public function deleteBlockDir(x:int, y:int):void
		{
			var my_color:int = board[y][x];
			board[y][x] = 0;
			//score += 10;        // スコアアップ
			score_num++;
			
			for ( var dx:int = -1; dx <= 1; dx++ ) {
				for ( var dy:int = -1; dy <= 1; dy++ ) {
					if ( (dx == 0 && dy == 0) || (dx != 0 && dy != 0) ) { continue; }
					if ( x + dx >= WIDTH || x + dx < 0 || y + dy >= HEIGHT || y + dy < 0 ) { continue; }
					if ( board[y + dy][x + dx] == my_color ) {
						deleteBlockDir(x + dx, y + dy);
					}
				}
			}
		}
		
		//---- ブロックを落とします
		public function fallBlock():void
		{
			var flag:Boolean = false;
			
			do {
				flag = false;
				for ( var i:int = 0; i < HEIGHT-1; i++ ) {
					for ( var j:int = 0; j < WIDTH; j++ ) {
						if ( board[i + 1][j] == 0 && board[i][j] != 0 ) {
							board[i + 1][j] ^= board[i][j];
							board[i][j] ^= board[i + 1][j];
							board[i + 1][j] ^= board[i][j];
							flag = true;
						}
					}
				}
			} while ( flag == true );
		}
		
		//---- 新しいブロックを追加
		public function addNewBlock():void
		{
			for ( var i:int = 0; i < HEIGHT; i++ ) {
				for ( var j:int = 0; j < WIDTH; j++ ) {
					if ( board[i][j] == 0 ) {
						board[i][j] = Math.round(Math.random() * (BLOCK_KIND-1)) + 1;
					}
				}
			}
		}
		
		//---- サーバーにスコア送信
		public function postScore(name:String):void
		{
			// 送信メッセージ
			var send_message:URLVariables = new URLVariables();
			send_message.name = name;
			send_message.score = score.toString;
			// 送信準備
			var request:URLRequest = new URLRequest(php_file);
			request.method = URLRequestMethod.POST;
			request.data = send_message;
			// 送信
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.load(request);
		}
    }
}