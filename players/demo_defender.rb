require_relative 'base'

module Players
    # 守備側プレイヤーを定義するクラス
    class Demo_Defender < Base
        INTERCEPTABLE_DISTANCE = 1.95 # 1.5 # 攻撃側の爆弾に対して「接触」したと判定される距離
        attr_accessor :g_sp, :speed, :dead

        # コンストラクタ
        def initialize(level: 0)
            # キャラクタの3D形状を定義する情報。MeshFactoryクラスに渡される
            attr = {
                geom_type: :box,
                mat_type: :phong,
                color: 0x0000ff
            }
            super(x: 0, y: level, z: 0, mesh_attr: attr)

            # 交差判定用Raycasterの向きを決定する単位ベクトルを生成する
            # @norm_vector = Mittsu::Vector3.new(0, 1, 0).normalize

            # 交差判定用のRaycasterオブジェクトを生成する
            @raycaster = Mittsu::Raycaster.new
            @speed = 0
            @g_sp = 0
            @speed_run = Mittsu::Vector3.new(0, 0, 0)
            # @fall_flag = 0
            @dead = 0
        end

        # キャラクタの移動に使用されるキーの定義
        def control_keys
            [
                :k_a, # 左移動
                :k_d,    # 右移動
                :k_w,    # 上移動
                :k_s,    # 下移動
                :k_space # ジャンプ
            ]
        end

        # 1フレーム分の進行処理
        def play(key_statuses, _selected_mode)
            # キーの押下状況に応じてX-Z平面を移動する。
            @speed_run.x -= 0.05 if key_statuses[control_keys[0]]
            @speed_run.x += 0.05 if key_statuses[control_keys[1]]
            @speed_run.z -= 0.05 if key_statuses[control_keys[2]]
            @speed_run.z += 0.05 if key_statuses[control_keys[3]]

            @speed_run.x = 0 if @speed_run.x.abs < 0.01
            @speed_run.z = 0 if @speed_run.z.abs < 0.01
            @speed_run.x = 0.4 if @speed_run.x > 0.4
            @speed_run.x = -0.4 if @speed_run.x < -0.4
            @speed_run.z = 0.4 if @speed_run.z > 0.4
            @speed_run.z = -0.4 if @speed_run.z < -0.4

            mesh.position.x += @speed_run.x
            mesh.position.z += @speed_run.z
            # if fall_flag == 1 then
                # self.mesh.position.y += 0.25
            # end
            mesh.position.x = 26 if mesh.position.x > 26
            mesh.position.x = -22 if mesh.position.x < -22
            mesh.position.z = 26 if mesh.position.z > 26
            mesh.position.z = -22 if mesh.position.z < -22

            @speed_run.x = @speed_run.x * 0.88
            @speed_run.z = @speed_run.z * 0.88

            if mesh.position.y > Directors::Game::DEFENDER_LEVEL
                @speed -= 0.1
            elsif key_statuses[control_keys[4]] && @g_sp == 0
                @speed = 1.0
            end
            mesh.position.y += @speed + @g_sp
            if mesh.position.y <= Directors::Game::DEFENDER_LEVEL && @speed.abs > 0 # 地面に埋まっていたら地面より上にあげる
                mesh.position.y = Directors::Game::DEFENDER_LEVEL
                @speed = 0
            end
            @dead = 1 if mesh.position.y < -16
        end

        # 爆弾迎撃メソッド。
        def intercept_bombs(bombs = [])
            intercepted_bombs = []
            hantei(bombs, Mittsu::Vector3.new(0, 1, 0).normalize).each do |obj|
                intercepted_bombs << obj
            end
            hantei(bombs, Mittsu::Vector3.new(1, 0, 0).normalize).each do |obj|
                intercepted_bombs << obj
            end
            hantei(bombs, Mittsu::Vector3.new(0, 0, 1).normalize).each do |obj|
                intercepted_bombs << obj
            end
            hantei(bombs,
                   Mittsu::Vector3.new(-1, 0, 0).normalize).each do |obj|
                intercepted_bombs << obj
            end
            hantei(bombs,
                   Mittsu::Vector3.new(0, 0, -1).normalize).each do |obj|
                intercepted_bombs << obj
            end
            intercepted_bombs
        end

        def hantei(bombs = [], vec)
            intercepted_bombs = []
            bomb_map = {}
            bombs.each do |bomb|
                bomb_map[bomb.mesh] = bomb
            end
            meshes = bomb_map.keys
            @raycaster.set(mesh.position, vec)
            collisions = @raycaster.intersect_objects(meshes)
            if collisions.size > 0
                obj = collisions.first[:object] # 最も近距離にあるオブジェクトを得る
                if meshes.include?(obj)
                    # 当該オブジェクトと、当たり判定元オブジェクトの位置との距離を測る
                    distance = mesh.position.distance_to(obj.position)
                    if distance <= INTERCEPTABLE_DISTANCE
                        intercepted_bombs << bomb_map[obj]
                        @dead = 1
                    end
                end
            end
            intercepted_bombs
        end
    end
end
