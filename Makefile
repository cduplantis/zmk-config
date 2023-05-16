shields=cradio_left cradio_right
config_dir=${PWD}/config
zmk_image=registry.hub.docker.com/zmkfirmware/zmk-dev-arm:3.2

docker_options= \
	--interactive \
	--tty \
	--name zmk-$@ \
	--workdir /zmk \
	--volume zmk:/zmk \
	--volume "${config_dir}:/zmk-config:Z" \
	${zmk_image}

codebase:
	docker run ${docker_options} sh -c '\
		git clone https://github.com/zmkfirmware/zmk /zmk/; \
		west init -l /zmk/app/; \
		west update'

clean:
	docker ps -aq --filter name='^zmk' | xargs -r docker container rm
	docker volume list -q --filter name='zmk' | xargs -r docker volume rm
	find uf2/ -type f -delete


shell:
	docker run --rm ${docker_options} /bin/bash

$(shields): 
	docker run --rm ${docker_options} \
		west build /zmk/app --pristine --board "nice_nano_v2" -- -DSHIELD="$@" -DZMK_CONFIG="/zmk-config"
	docker cp zmk-codebase:/zmk/build/zephyr/zmk.uf2 uf2/$@.uf2
