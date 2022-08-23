require_relative 'mesh_factory'

# 地表オブジェクトを定義するクラス
class Ground
	# 地表の3D形状へのアクセサ
	attr_reader :mesh, :bomb_flag
	GROUND_LEVEL = -9
	GROUND_SIZE = 4.0
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
		@bomb_flag = 0
	end
	def fall(count: 0)
		@fall_count = count
	end
	def ground(bombs)
		nbombs = []
		nbombs = bombs
		
		@bomb_flag = 0
		pos_x = @mesh.position.x
		pos_z = @mesh.position.z
		nbombs.each do |bomb|
			if(pos_x- GROUND_SIZE/2 <= bomb.mesh.position.x && bomb.mesh.position.x <= pos_x + GROUND_SIZE/2&& pos_z-GROUND_SIZE/2 <= bomb.mesh.position.z && bomb.mesh.position.z <= pos_z+GROUND_SIZE/2) then
				@bomb_flag = 1
			end
		end

		if @fall_count > 0 then
			@fall_count += -1
			if @scene_flag == 0 then
				@scene_flag = 1
				@mesh.position.y = 1000
			end
		else
			if @scene_flag == 1 then
				@scene_flag = 0
				@mesh.position.y = GROUND_LEVEL
			end
		end
		if @bomb_flag == 1 then
			@mesh.material.color.set(0x00ff00)
		else
			@mesh.material.color.set(0xff0000)
		end
	end
end
