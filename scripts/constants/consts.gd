class_name Consts

const DEFAULT_VIEWPORT_HEIGHT: int = 720

const INITIAL_BUDGET: int = 350

const TRANSPORT_COST_1000: int = 25

const MESSAGE_INFO: int = 0
const MESSAGE_WARNING: int = 1
const MESSAGE_ERROR: int = 2

const MESSAGE_ICONS = {
	MESSAGE_INFO: preload("res://assets/icons/menu/info.svg"),
	MESSAGE_WARNING: preload("res://assets/icons/menu/warning.svg"),
	MESSAGE_ERROR: preload("res://assets/icons/menu/error.svg"),
}

const MESSAGE_ICONS_LARGE = {
	MESSAGE_INFO: preload("res://assets/icons/menu/info_48px.svg"),
	MESSAGE_WARNING: preload("res://assets/icons/menu/warning_48px.svg"),
	MESSAGE_ERROR: preload("res://assets/icons/menu/error_48px.svg"),
}

const SAVEGAME_DIR = "save"
const CONFIG_DIR = "config"

const DRAW_HEIGHT_OFFSET: float = 0.01
const ROAD_WIDTH: float = 0.03


const LAYER_BASE: int = 0
const LAYER_LABELS: int = 1
const LAYER_LAND_USE: int = 2
const LAYER_ROADS: int = 3
const LAYER_RESOURCES: int = 4
const LAYER_CITY_RANGES: int = 5
const LAYER_DEFENSE_RANGES: int = 6
const LAYER_EVENTS: int = 7
