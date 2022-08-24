LIMITATION_MODE = :SCORE_BOARD  # FIXME: "demo.rb" only supports :SCORE_BOARD
case LIMITATION_MODE
when :TIME_BOARD then
    if SkeletonsInHole::Base::ENTRYPOINT_PATH.end_with?("demos.rb")
        raise "Not Supported Combination of TimeBoard with demos.rb"
    end
	require_relative 'time_board'
    require_relative 'camera_for_time'
    Camera = CameraForTime
when :SCORE_BOARD then
	require_relative 'score_board'
    require_relative 'camera_for_score'
    Camera = CameraForScore
else
	raise "Choose either :TIME_BOARD or :SCORE_BOARD for drawing on the display"
end
