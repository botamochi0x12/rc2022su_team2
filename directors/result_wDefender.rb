require_relative 'base'

module Directors
	# タイトル画面のシーン制御用ディレクタークラス
	class Result_wDefender < Base
		# コンストラクタ
		def initialize(renderer:, aspect:)
			# スーパークラスのコンストラクタ実行
			super

			# タイトル画面の次に遷移する画面（ゲーム本編）用のディレクターオブジェクトを生成
			#@game_director = Directors::Result.new(renderer: renderer, aspect: aspect)

			# 地球のメッシュを生成してシーンに追加
			@earth = MeshFactory.get_earth
			self.scene.add(@earth)

			# テキスト用ボードオブジェクト追加
			#vs_com_board = TextBoard.new(texture_path: "textures/title_vs_com.png", value: Directors::Game::VS_COM_MODE)
			#vs_player_board = TextBoard.new(texture_path: "textures/title_vs_player.png", value: Directors::Game::VS_PLAYER_MODE, y: -2)
			#self.scene.add(vs_com_board.mesh)
			#self.scene.add(vs_player_board.mesh)
			#@selectors = {
				#vs_com_board.mesh => vs_com_board,
				#vs_player_board.mesh => vs_player_board
			#}
			# Raycasterとマウス位置の単位ベクトルを収めるオブジェクトを生成
			#@raycaster = Mittsu::Raycaster.new
			#@mouse_position = Mittsu::Vector2.new

			@Win_Defender = TextBoard.new(texture_path: "textures/Win_Defender.png",value: "Win_Defender",x:0,y:0,z:7,w:10,h:5)#
			#@Win_Attacker.mesh.position.x
			#@Win_Attacker.mesh.scale_y = 8
			self.scene.add(@Win_Defender.mesh)

			# 光源追加
			add_lights

			# Mittsuのイベントをアクティベート（有効化）する
			#activate_events
		end

		# 1フレーム分のゲーム進行処理
		def render_frame
			# 少しずつ地球のメッシュを回転させる（自転を表現）
			@earth.rotate_y(0.001)
			
		end

		def add_lights
			# 地球を照らすための照明
			earth_light = Mittsu::DirectionalLight.new(0xffffff)
			earth_light.position.set(5, 10, 5)
			self.scene.add(earth_light)

			# 文字ボードを照らすための照明
			text_light = Mittsu::SpotLight.new(0xffffff)
			text_light.angle = Math::PI / 2
			text_light.position.set(0, -1, 10)
			self.scene.add(text_light)
		end
	end
end
