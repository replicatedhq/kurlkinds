# Copyright 2022 Replicated Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# 	http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
package kurl.installer

# informs that we are linting a marshaled installer.
lint[output] {
	debug_enabled
	input.content
	output :=  {
		"type": "debug",
		"message": "debugging a marshaled installer",
	}
}

# informs that we are linting an unmarshaled installer.
lint[output] {
	debug_enabled
	not input.content
	output :=  {
		"type": "debug",
		"message": "debugging an unmarshaled installer",
	}
}

# informs the object being analyzed.
lint[output] {
	debug_enabled
	output :=  {
		"type": "debug",
		"message": sprintf("installer: %v", [json.marshal(installer)])
	}
}

# informs the base url we are using to fetch add-on versions.
lint[output] {
	debug_enabled
	output :=  {
		"type": "debug",
		"message": sprintf("api_base_url: %v", [api_base_url])
	}
}

# informs the ful url we are using to fetch add-on versions.
lint[output] {
	debug_enabled
	output :=  {
		"type": "debug",
		"message": sprintf("add_ons_versions_endpoint: %v", [add_ons_versions_endpoint])
	}
}

# returns the full body of the remote_versions request.
lint[output] {
	debug_enabled
	output :=  {
		"type": "debug",
		"message": sprintf("remote_versions body: %v", [remote_versions.raw_body])
	}
}

# returns the remote_versions request status.
lint[output] {
	debug_enabled
	output :=  {
		"type": "debug",
		"message": sprintf("remote_versions status: %v", [remote_versions.status])
	}
}
