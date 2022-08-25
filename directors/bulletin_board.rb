# bulletin_boardmv 
require_relative 'base'

# TODO: Show lines of playernames that servived this game.
# TODO: Transition to the Game Over scence.
module Directors
	class BulletinBoard < Base

        def initialize(renderer:, aspect:, camera: nil)
            super
			
			# TODO: Create a score board UI
			# score_board = TextBoard.new(texture_path: "textures/designed_score_board.png")
			# self.scene.add(score_board.mesh)
			
			@_next_director = nil 
			# Directors::GameOver.new(renderer: renderer, aspect: aspect)
        end

		# @override
		# 1フレーム分のゲーム進行処理
		def render_frame
			if escape_key_pressed 
				_transition_to_game_over
			end
		end

		private

		def _transition_to_game_over
			# 次のシーンを担当するディレクターのMittsuイベントのアクティベートを行う。
			# ※ シーンを切り替える瞬間に行わないと、後発のディレクターのイベントハンドラで先発のイベントハンドラが
			#    上書きされてしまうため、このタイミングで実行する。
			@game_director.activate_events

			# next_directorアクセサを切り替えることで、次のフレームの描画からシーンが切り替わる。
			# ※ このメカニズムはmain.rb側のメインループで実現している点に注意
			self.next_director = @_next_director
		end
    end
end
