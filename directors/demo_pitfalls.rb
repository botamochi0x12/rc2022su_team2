require_relative 'base'

module Directors
    # ゲーム本編のシーン制御用ディレクタークラス
    class DemoPitfalls < Base
        attr_accessor :selected_mode

        VS_COM_MODE = "com"
        VS_PLAYER_MODE = "player"

        ATTACKER_LEVEL = 8    # 攻撃側プレイヤーの「高度」（Y座標値）
        DEFENDER_LEVEL = -8   # 防御側プレイヤーの「高度」（Y座標値）
        GROUND_LEVEL = -9     # 地面オブジェクトの「高度」（Y座標値）
        GROUND_SIZE = 4.0 # 地面オブジェクトの広がり（面積）。地面オブジェクトは正方形のBoxで表現する
        GROUND_K = 12 # 縦横何マスか
        # コンストラクタ
        def initialize(renderer:, aspect:)
            # スーパークラスのコンストラクタ実行
            super

            # Mittsuのイベントをアクティベート（有効化）する
            activate_events

            # ゲームモード（対人・対COMの選択）のデフォルトを定義
            self.selected_mode = VS_COM_MODE

            # SkyBoxをシーンに追加する
            @skybox = SkyBox.new
            scene.add(@skybox.mesh)

            # 光源をシーンに追加する
            add_lights

            # 地面を表現するオブジェクトを生成してシーンに登録
            @cubes = []
            for i in 0..(GROUND_K - 1)
                for j in 0..(GROUND_K - 1)
                    @cubes << (Ground.new(size: GROUND_SIZE, level: GROUND_LEVEL,
                                          pox: 24 + ((-GROUND_SIZE) * i), poz: 24 + ((-GROUND_SIZE) * j)))
                end
            end
            @cubes.each { |cube| scene.add(cube.mesh) }
            # 攻撃側（上側）、防御側（下側）のそれぞれのプレイヤーキャラクタを生成
            @players = []
            @players << Players::Attacker.new(level: ATTACKER_LEVEL)
            @players << Players::Demo_Defender.new(level: DEFENDER_LEVEL)
            @select_sabotage = 0
            camera.position.z = 30
            camera.position.y = 25
            camera.rotation.x = -1
            camera.instance_eval do
                def mouse_moved(position:)
                    # DO nothing
                end

                def mouse_wheel_scrolled(offset:)
                    # DO nothing
                end
            end
            # 各プレイヤーのメッシュをシーンに登録
            @players.each { |player| scene.add(player.mesh) }
            # 攻撃側が落とす爆弾の保存用配列を初期化
            @bombs = []

            # 攻撃側プレイヤーの獲得スコアの初期化
            @score = 0
            @mouse_position = Mittsu::Vector2.new
            @raycaster = Mittsu::Raycaster.new
            @container = Mittsu::Object3D.new
            @sabo_list = []
            @dead_flag = 0
            @select_ground = 0
            @result_wAttacker_director = Directors::Result_wAttacker.new(
                renderer: renderer, aspect: aspect
            )
            @result_wDefender_director = Directors::Result_wDefender.new(
                renderer: renderer, aspect: aspect
            )
        end

        # 1フレーム分のゲーム進行処理
        def render_frame
            for i in 0..(GROUND_K - 1)
                for j in 0..(GROUND_K - 1)
                    @cubes[j + (i * GROUND_K)].ground(@bombs)
                    pos_x = @cubes[j + (i * GROUND_K)].mesh.position.x
                    pos_z = @cubes[j + (i * GROUND_K)].mesh.position.z
                    d = (GROUND_SIZE - 1) / 2
                    pos = [pos_x - d, pos_x + d, pos_z - d, pos_z + d]
                    if i - 1 > 0 && !(@cubes[j + ((i - 1) * GROUND_K)].fall_count > 0 && @cubes[j + ((i - 1) * GROUND_K)].wait_count == 0)
                        pos[0] = pos_x - (GROUND_SIZE / 2)
                    end
                    if i + 1 < (GROUND_K) && !(@cubes[j + ((i + 1) * GROUND_K)].fall_count > 0 && @cubes[j + ((i + 1) * GROUND_K)].wait_count == 0)
                        pos[1] = pos_x + (GROUND_SIZE / 2)
                    end
                    if j - 1 > 0 && !(@cubes[(j - 1) + (i * GROUND_K)].fall_count > 0 && @cubes[(j - 1) + (i * GROUND_K)].wait_count == 0)
                        pos[2] = pos_z - (GROUND_SIZE / 2)
                    end
                    if j + 1 < (GROUND_K) && !(@cubes[(j + 1) + (i * GROUND_K)].fall_count > 0 && @cubes[(j + 1) + (i * GROUND_K)].wait_count == 0)
                        pos[3] = pos_z + (GROUND_SIZE / 2)
                    end
                    unless pos[0] < @players[1].mesh.position.x && @players[1].mesh.position.x < pos[1] && pos[2] < @players[1].mesh.position.z && @players[1].mesh.position.z < pos[3]
                        next
                    end

                    unless @cubes[j + (i * GROUND_K)].fall_count > 0 && @cubes[j + (i * GROUND_K)].wait_count == 0
                        next
                    end

                    if @players[1].speed.abs == 0 && @players[1].mesh.position.y <= -8
                        @players[1].g_sp -= 0.1
                    end
                end
            end
            @players.each do |player|
                key_statuses = check_key_statuses(player)
                player.play(key_statuses, selected_mode)
                add_bombs(player.collect_bombs)
                intercept(player)
            end

            erase_bombs
            camera.draw_score(@score)
            camera.draw_sabotage(@select_sabotage)
            # 選択しているマス
            @mouse_position.x = (((@renderer.window.mouse_position.x / SCREEN_WIDTH) * 2.0) - 1.0)
            @mouse_position.y = (((@renderer.window.mouse_position.y / SCREEN_HEIGHT) * -2.0) + 1.0)
            # 当たり判定実行
            @raycaster.set_from_camera(@mouse_position, camera.instance)
            ground_array = []
            @cubes.each do |cube|
                ground_array << cube.mesh
            end
            intersects = @raycaster.intersect_objects(ground_array)
            for i in 0..(GROUND_K - 1)
                for j in 0..(GROUND_K - 1)
                    @cubes[j + (i * GROUND_K)].init_selected_ground
                end
            end
            intersects.each do |intersect|
                p "#{intersect[:object].position.x} #{intersect[:object].position.z}" # テスト用
                i_index = (intersect[:object].position.x - 24) / -GROUND_SIZE
                j_index = (intersect[:object].position.z - 24) / -GROUND_SIZE
                if @select_sabotage == 1 || @select_sabotage == 2
                    for i in 0..(GROUND_K - 1)
                        @cubes[j_index + (i * GROUND_K)].selected_ground
                    end
                elsif @select_sabotage == 3 || @select_sabotage == 4
                    for i in 0..(GROUND_K - 1)
                        @cubes[i + (i_index * GROUND_K)].selected_ground
                    end
                else
                    @cubes[j_index + (i_index * GROUND_K)].selected_ground
                end
                @select_ground = j_index + (i_index * GROUND_K)
            end
            if @players[1].dead == 1 && @dead_flag == 0
                @dead_flag = 1
                puts "Defender fell into a pitfall"
                if false
                    self.next_director = @result_wAttacker_director
                    @result_wAttacker_director.activate_events
                end
            end
            puts "The next scene is #{next_director}"
        end

        private

        # 爆弾迎撃処理
        def intercept(player)
            removed_bombs = player.intercept_bombs(@bombs)
            removed_bombs.each { |bomb| scene.remove(bomb.mesh) }
            @bombs -= removed_bombs
        end

        # 地面（Ground）レベルまで落下した爆弾の消去処理
        def erase_bombs
            removed_bombs = Bomb.operation(@bombs, GROUND_LEVEL)
            removed_bombs.each { |bomb| scene.remove(bomb.mesh) }
            @bombs -= removed_bombs
            @score += removed_bombs.size
        end

        def mouse_released(button:, position:)
            case button
            # クリックされたボタンが左クリックである場合
            when :m_left
                @cubes[@select_ground].click_event(@select_sabotage,
                                                   @players[0])
            end
        end

        # シーンに爆弾を追加
        def add_bombs(bombs)
            bombs.each do |bomb|
                scene.add(bomb.mesh)
                @bombs << bomb
            end
        end

        # プレイヤーが必要とするキーの押下情報をハッシュ形式にまとめる。
        def check_key_statuses(player)
            result = {}
            player.control_keys.each do |key|
                result[key] = key_down?(key: key)
            end
            result
        end

        # カメラ視点操作用イベントハンドラ（マウスクリック検知）オーバーライド
        # これらのイベントハンドラメソッドの元はBaseクラスに定義しているので、必要に応じて参照してください。
        #
        # ※ Forwardableモジュールを用いてcameraオブジェクトにdelegate(移譲)するとよりシンプルに記述可能です。
        #    興味のある人は https://ruby-doc.org/stdlib-2.7.1/libdoc/forwardable/rdoc/Forwardable.html などを参照。
        #    require 'forwardable'
        #    とした上で、
        #    ````
        #    extend Forwardable
        #    delegate mouse_clicked: :camera
        #    ````
        #    のように移譲すればこのメソッドは記述しなくてもよくなる。
        def mouse_clicked(button:, position:)
            camera.mouse_clicked(button: button, position: position)
        end

        # カメラ視点操作用イベントハンドラ（マウスホイールのスクロール検知）オーバーライド
        def mouse_wheel_scrolled(offset:)
            if offset.y > 0
                if @select_sabotage > 0
                    @select_sabotage += -1
                else
                    @select_sabotage = 5
                end
            elsif offset.y < 0
                if @select_sabotage < 5
                    @select_sabotage += 1
                else
                    @select_sabotage = 0
                end
            end
        end

        # カメラ視点操作用イベントハンドラ（マウスカーソルの移動検知）オーバーライド
        # ※ このメソッドは、Base#mouse_button_down?を使っているので単純にdelegateはできない（無理ではないが大変）点に注意。
        def mouse_moved(position:)
            camera.mouse_moved(position: position) if mouse_button_down?
        end

        # シーンに光源を追加
        def add_lights
            light = Mittsu::PointLight.new(0xffffff)
            light.position.set(1, 7, 1)
            scene.add(light)
        end
    end
end
