package travis;

interface Api {
	@:sub('/repo')
	var repos:Repos;
	@:sub('/job')
	var jobs:Jobs;
}

interface Repos {
	@:sub('/$id')
	function ofId(id:Int):Repo;
	
	@:sub('/$slug')
	function ofSlug(slug:String):Repo;
}

interface Repo {
	@:sub
	var builds:Builds;
}

interface Builds {
	@:sub('/$id')
	function ofId(id:Int):Build;
	
	@:get('/')
	function list():BuildsResponse;
}

interface Build {
	@:sub
	var builds:Builds;
}

interface Jobs {
	@:sub('/$id')
	function ofId(id:Int):Job;
	
}

interface Job {
	@:get
	function log():LogResponse;
}



typedef BaseResponse = {
	// @:native('@type') var _type:String;
}

typedef BuildsResponse = {
	> BaseResponse,
	builds:Array<BuildResponse>
}

typedef BuildResponse = {
	> BaseResponse,
	id:Int,
	jobs:Array<JobResponse>,
}

typedef JobResponse = {
	> BaseResponse,
	id:Int,
}

typedef LogResponse = {
	> BaseResponse,
	id:Int,
	content:String,
}