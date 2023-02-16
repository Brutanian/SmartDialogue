extends Resource
class_name FlowMapResource

@export var MapName : StringName = "NewMap"
@export var FileName : StringName = "NewMap"

@export var AllFlowLists : Array[FlowListResource]

@export var FlowListInstances : Array[Dictionary]

@export var Constants : Dictionary
@export var Local : Dictionary
@export var Global : Dictionary
@export var Groups : Dictionary #Sub-Dictionaries

var MapNode : Node2D

signal VariablesChanged()
signal FlowListsChanged()

func GetCustomGroups():
	return Groups.keys()

func GetGroup(Name : String):
	match Name:
		"Global":
			return Global
		"Local":
			return Local
		"Constants":
			return Constants
	return Groups[Name]

func SetGroup(Name : String, NewVars : Dictionary):
	match Name:
		"Global":
			Global = NewVars
			VariablesChanged.emit()
			return
		"Local":
			Local = NewVars
			VariablesChanged.emit()
			return
		"Constants":
			Constants = NewVars
			VariablesChanged.emit()
			return
	Groups[Name] = NewVars
	VariablesChanged.emit()

func NewFlowList(FlowList : FlowListResource):
	AllFlowLists.append(FlowList)
	FlowListsChanged.emit()

func SetInstanceProperties(Instance : int, Properties : Dictionary):
	if !AllFlowLists.has(Properties.FlowList):
		NewFlowList(Properties.FlowList)
	FlowListInstances[GetInstanceIndex(Instance)] = Properties

func GetInstanceProperties(Instance : int):
	return FlowListInstances[GetInstanceIndex(Instance)]

func CreateNewInstance(Properties : Dictionary):
	FlowListInstances.append(Properties)
	return len(FlowListInstances)-1

func RemoveInstance(Instance : int):
	FlowListInstances.remove_at(GetInstanceIndex(Instance))

func GetInstanceIndex(Instance : int):
	for i in len(FlowListInstances):
		if FlowListInstances[i].Instance == Instance:
			return i
	return -1

func NewUniqueInstanceID():
	var Instance : int = len(FlowListInstances)
	while GetInstanceIndex(Instance) != -1:
		Instance += 1 
	return Instance

func CreateObjFromIndex(Index : int):
	var New = preload("res://FlowList.tscn").instantiate()
	New.OwnerFlowMap = self
	New.LoadProperties(FlowListInstances[Index])
	return New

func CreateObjsFromInstances():
	var Objs : Array
	for i in len(FlowListInstances):
		Objs.append(CreateObjFromIndex(i))
	return Objs

func SetOptionsAsLists(Options : OptionButton):
	Options.clear()
	for i in AllFlowLists:
		Options.add_item(i.ListName)

func SetName(NewName : StringName):
	MapName = NewName
	if FileName == "":
		FileName = NewName

func Save():
	if MapName != FileName:
		var Err = ResourceSaver.save(self,"res://FlowMaps/%s.tres" % MapName)
		if Err == OK:
			DirAccess.remove_absolute("res://FlowMaps/%s.tres" % FileName)
			FileName = MapName
	ResourceSaver.save(self,"res://FlowMaps/%s.tres" % FileName)

static func Load(FilePath : String):
	var New = ResourceLoader.load(FilePath)
	return New
