# 攻撃側プレイヤーが地表に爆弾を到達させた際に獲得する点数を表示するためのクラス
class SabotageBoard
	# スプライトの集合体（得点板そのもの）へのアクセサ
	attr_reader :container

	# コンストラクタ
	# * x, y: 得点板を表示する座標（3Dシーン内のX-Y平面上の座標を指定する）
	# ※ 得点板はスプライトで表現するため、Z座標は気にする必要が無い。
	def initialize(x:, y:)
		@x, @y = x, y
		@container = Mittsu::Object3D.new
		@sprites = []
		@prev_sabotage = -1

		# 0～9までの数字を表現するためのマテリアルオブジェクトを定義
		@materials = {
			mat_0:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/pitfall_0.png')),
			mat_1:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/pitfall_1.png')),
			mat_2:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/MIGI_0.png')),
			mat_3:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/MIGI_1.png')),
			mat_4:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/HIDARI_0.png')),
			mat_5:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/HIDARI_1.png')),
			mat_6:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/MAE_0.png')),
			mat_7:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/MAE_1.png')),
			mat_8:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/USHIRO_0.png')),
			mat_9:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/USHIRO_1.png')),
			mat_10:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/SHITA_0.png')),
			mat_11:Mittsu::SpriteMaterial.new(map: MeshFactory.get_texture('textures/SHITA_1.png')),
		}
	end

	# 与えられたスコアを得点板に表示する
	def draw_sabotage(sabotage_board)
		
		return if @prev_sabotage == sabotage_board
		
		x = @x
		
		remove_exists_sprites
		for i in 0..5
			sprite = generate_sprite(i*2, x, @y) if i != sabotage_board
			sprite = generate_sprite(i*2+1, x, @y) if i == sabotage_board
			@sprites << sprite
			@container.add(sprite)
			x += 1
		end
		
		@prev_sabotage = sabotage_board
		

	end

	private

	# 得点板を書き換えるために一度全スプライトをコンテナオブジェクトから消す
	def remove_exists_sprites
		@sprites.each do |sprite|
			@container.remove(sprite)
		end
		@sprites = []
	end

	# コンテナオブジェクトに数字1文字を貼り付けたスプライトを登録する
	# ※ このスプライトを4つ横に並べて得点板を表現している
	def generate_sprite(number, x, y)
		mat = @materials[("mat_"+(number).to_s).to_sym]
		sprite = Mittsu::Sprite.new(mat)
		sprite.position.x = x
		sprite.position.y = y
		#sprite.position.z = -5
		sprite
	end
end
