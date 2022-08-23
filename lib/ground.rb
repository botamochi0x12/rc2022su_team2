require_relative 'mesh_factory'

# 地表オブジェクトを定義するクラス
class Ground
	# 地表の3D形状へのアクセサ
	attr_reader :mesh,  :fall_count,  :scene_flag
	GROUND_LEVEL = -9
	# コンストラクタ
	def initialize(size: 30.0, level: 0, pox:0,poz:0)
		@mesh = MeshFactory.generate(
			geom_type: :box,
			mat_type: :phong,
			scale_x: size,
			scale_y: 0.1,
			scale_z: size
		)
		@mesh.position.y = level
		@mesh.position.x = pox
		@mesh.position.z = poz
		@fall_count = 0
		@scene_flag = 0
	end
	def fall(count: 0)
		@fall_count = count
	end
	def fall_ground
		if @fall_count > 0 then
			@fall_count += -1
			if @scene_flag == 0 then
				@scene_flag = 1
				@mesh.position.y = 100
			end
		else
			if @scene_flag == 1 then
				@scene_flag = 0
				@mesh.position.y = GROUND_LEVEL
			end
		end
	end
end
