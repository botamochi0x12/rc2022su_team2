# 文字列テクスチャを画面に表示するための板ポリゴンを管理するクラス
class TextBoard
	attr_reader :mesh, :value

	DEFAULT_X = 0
	DEFAULT_Y = 0
	DEFAULT_Z = 7
	DEFAULT_W = 10.0
	DEFAULT_H = 1.0

	# コンストラクタ
	def initialize(texture_path:, value:, x: DEFAULT_X, y: DEFAULT_Y, z: DEFAULT_Z,w:DEFAULT_W,h:DEFAULT_H)
		# テキストテクスチャを貼り付けた板オブジェクトを生成する。
		@mesh = MeshFactory.generate(
			geom_type: :plane,
			mat_type: :lambert,
			scale_x: w,
			scale_y: h,
			segment_x: 10,
			segment_y: 1,
			texture_map: MeshFactory.get_texture(texture_path)
		)

		# 板オブジェクトの表示位置を決定する。
		@mesh.position = Mittsu::Vector3.new(x, y, z)

		# このテキストボードを選択（クリック）した際に次のシーンに送る値を定義する。
		# ※ クリック判定はディレクターオブジェクトで行う。
		@value = value
	end
end
