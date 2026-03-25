class_name EntityState
extends Node

var machine: EntityStateMachine
signal transition

func init(m):
	machine = m

func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	pass
	
func enter():
	pass
	
func exit():
	pass
