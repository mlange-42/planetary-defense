extends Control
class_name ProductionInfo


func set_commodity(comm: String):
	$CommLabel.text = comm


func set_values(source: int, moved: int, sink: int):
	$SourceSink/SourceLabel.text = str(source)
	$SourceSink/MovedLabel.text = str(moved)
	$SourceSink/SinkLabel.text = str(sink)
