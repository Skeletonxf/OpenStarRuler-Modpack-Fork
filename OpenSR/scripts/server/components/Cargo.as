import cargo;
from objects.Asteroid import createAsteroid;

tidy class Cargo : CargoStorage, Component_Cargo {
	void getCargo() {
		yield(this);
	}

	double get_cargoCapacity() {
		return capacity;
	}

	double get_cargoStored() {
		return filled;
	}

	double getCargoStored(uint typeId) {
		auto@ type = getCargoType(typeId);
		if(type is null)
			return -1.0;
		return get(type);
	}

	uint get_cargoTypes() {
		if(types is null)
			return 0;
		return types.length;
	}

	uint get_cargoType(uint index) {
		if(types is null)
			return uint(-1);
		if(index >= types.length)
			return uint(-1);
		return types[index].id;
	}

	void modCargoStorage(double amount) {
		capacity += amount;
		delta = true;
	}

	void overrideCargoStorage(double amount) {
		capacity = amount;
		delta = true;
	}

	void addCargo(uint typeId, double amount) {
		auto@ type = getCargoType(typeId);
		if(type is null)
			return;
		add(type, amount);
	}

	void removeCargo(uint typeId, double amount) {
		auto@ type = getCargoType(typeId);
		if(type is null)
			return;
		consume(type, amount, true);
	}

	double consumeCargo(uint typeId, double amount, bool partial = false) {
		auto@ type = getCargoType(typeId);
		if(type is null)
			return 0.0;
		return consume(type, amount, partial);
	}

	void transferAllCargoTo(Object@ other) {
		transferAllCargoToFixed(other, 0.0);
	}

	void transferAllCargoToFixed(Object@ other, double limit) {
		if(types is null || !other.hasCargo)
			return;
		double cap = other.cargoCapacity - other.cargoStored;
		if (limit > 0.0) {
			cap = min(cap, limit);
		}
		while(cap > 0 && types.length > 0) {
			auto@ type = types[0];
			double cons = min(cap / type.storageSize, amounts[0]);
			cons = consume(type, cons, partial=true);
			if(cons > 0) {
				other.addCargo(type.id, cons);
				cap -= cons;
			}
			else {
				break;
			}
		}
	}

	void transferPrimaryCargoTo(Object@ other, double rate) {
		if(types is null || types.length == 0)
			return;
		auto@ type = types[0];
		double realAmount = rate / type.storageSize;
		realAmount = consume(type, realAmount, partial=true);
		if(realAmount > 0)
			other.addCargo(type.id, realAmount);
	}

	void transferCargoTo(uint typeId, Object@ other) {
		transferCargoToFixed(typeId, other, 0.0);
	}

	void transferCargoToFixed(uint typeId, Object@ other, double limit) {
		if(types is null || types.length == 0)
			return;
		auto@ type = getCargoType(typeId);
		if(type is null)
			return;

		double stored = getCargoStored(typeId);
		if(stored != 0.0) {
			double cap = other.cargoCapacity - other.cargoStored;
			if (limit > 0.0) {
				cap = min(cap, limit);
			}
			double cons = min(cap / type.storageSize, stored);
			cons = consume(type, cons, partial=true);
			if(cons > 0) {
				other.addCargo(type.id, cons);
				cap -= cons;
			}
		}
	}

	void writeCargo(Message& msg) {
		msg << this;
	}

	bool writeCargoDelta(Message& msg) {
		if(!delta)
			return false;
		msg.write1();
		writeCargo(msg);
		delta = false;
		return true;
	}

	void destroyCargo(Object& obj) {
		for(uint i = 0; i < getCargoTypeCount(); i++) {
			double cargoStored = getCargoStored(i);
			if (cargoStored > 0) {
				const CargoType@ type = getCargoType(i);
				if (type is null || false /* TODO !type.dropsOnDeath*/) {
					continue;
				}
				Asteroid@ roid = createAsteroid(obj.position + vec3d(randomd(-20, 20), 0.0, randomd(-20, 20)), delay=true);
				Region@ reg = obj.region;
				if(reg !is null) {
					roid.orbitAround(reg.position);
					roid.orbitSpin(randomd(20.0, 60.0));
				}
				roid.addCargo(i, randomd(0.5, 1) * cargoStored);
				roid.initMesh();
			}
		}
	}
};
