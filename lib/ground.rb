require_relative 'mesh_factory'

# 地表オブジェクトを定義するクラス
class Ground
	# 地表の3D形状へのアクセサ
	attr_reader :mesh, :bomb_flag, :fall_count, :wait_count
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
		@wait_count = 0
		@scene_flag = 0
		@bomb_flag = 0
		@select_flag = 0
	end
	def fall(count: 0,wait:0)
		@fall_count = count
		@wait_count = wait
	end
	def selected_ground
		@select_flag = 1
	end
	def init_selected_ground
		@select_flag = 0
	end
	def click_event(select_sabotage,player)
		if @select_flag == 1 then
			fall(count:120,wait: 30) if select_sabotage == 0
			#@mesh.position.x
			if select_sabotage == 1 then
				pos = Mittsu::Vector3.new(-27,-8,@mesh.position.z)
				spe = Mittsu::Vector3.new(0.5,0,0)
				player.bomb(pos,spe)
			elsif select_sabotage == 2 then
				pos = Mittsu::Vector3.new(27,-8,@mesh.position.z)
				spe = Mittsu::Vector3.new(-0.5,0,0)
				player.bomb(pos,spe)
			elsif select_sabotage == 4 then
				pos = Mittsu::Vector3.new(@mesh.position.x,-8,27)
				spe = Mittsu::Vector3.new(0,0,-0.5)
				player.bomb(pos,spe)
			elsif select_sabotage == 3 then
				pos = Mittsu::Vector3.new(@mesh.position.x,-8,-27)
				spe = Mittsu::Vector3.new(0,0,0.5)
				player.bomb(pos,spe)
			elsif select_sabotage == 5 then
				pos = Mittsu::Vector3.new(@mesh.position.x,8,@mesh.position.z)
				spe = Mittsu::Vector3.new(0,-0.1,0)
				player.bomb(pos,spe)
			end
		end
	end
	def ground(bombs)
		g_size = Directors::Game::GROUND_SIZE
		nbombs = []
		nbombs = bombs
		@bomb_flag = 0
		pos_x = @mesh.position.x
		pos_z = @mesh.position.z
		nbombs.each do |bomb|
			if(pos_x - g_size/2 <= bomb.mesh.position.x && bomb.mesh.position.x <= pos_x + g_size/2&& pos_z-g_size/2 <= bomb.mesh.position.z && bomb.mesh.position.z <= pos_z+g_size/2) then
				@bomb_flag = 1
			end
		end
		if @wait_count > 0 then
			@wait_count += -1
		elsif @fall_count > 0 then
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
		if @wait_count > 0 && @wait_count%4 == 0 then
			@mesh.material.color.set(0xffff00)
		elsif @bomb_flag == 1 then
			@mesh.material.color.set(0x00ff00)
		elsif @select_flag == 1 && @wait_count == 0 then
			@mesh.material.color.set(0x0000ff)
		else
			@mesh.material.color.set(0xff0000)
		end
	end
end
