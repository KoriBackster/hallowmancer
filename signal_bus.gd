extends Node

var active_signals:Dictionary[StringName,Array]

func recieve(sig:Signal, tag:StringName)->void:
	var a_sig_keys:=active_signals.keys()
	if a_sig_keys.has(tag) and active_signals[tag].has(sig):
		return
	elif a_sig_keys.has(tag):
		active_signals[tag].append(sig)
	else:
		active_signals[tag] = [sig]

func send(signal_list:Array[Signal])->void:
	var unique_tag:StringName = StringName(String.num_uint64(randi(), 16, true))
	print(unique_tag)
	for sig:Signal in signal_list:
		var is_recieve_bound:bool
		for conn:Dictionary in sig.get_connections():
			if is_recieve_bound:
				break
			elif conn["callable"] == recieve:
				is_recieve_bound = true
		if not is_recieve_bound:
			sig.connect(recieve, 20)
		sig.emit(unique_tag)
		
