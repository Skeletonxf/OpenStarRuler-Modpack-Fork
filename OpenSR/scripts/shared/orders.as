enum OrderType {
	OT_Attack,
	OT_Goto,
	OT_Hyperdrive,
	OT_Move,
	OT_PickupOrder,
	OT_Capture,
	OT_Scan,
	OT_Refresh,
	OT_Fling,
	OT_OddityGate,
	OT_Slipstream,
	OT_Ability,
	OT_AutoExplore,
	OT_Wait,
	OT_Jumpdrive,
	OT_Chase,
	OT_Cargo,
	OT_AutoMine,
	OT_Loop,
	OT_INVALID
};

bool isFTLOrder(uint type) {
	return type == OT_Hyperdrive || type == OT_Slipstream || type == OT_Fling || type == OT_Jumpdrive;
}

class OrderDesc : Serializable {
	uint type;
	bool hasMovement;
	vec3d moveDestination;
	// Extra info for the clients so they can present cargo
	// order options smartly.
	int cargoId = -1;
	bool isPickup = false;
	bool isDropoff = false;

	void write(Message& msg) {
		msg << uint(type);
		if(hasMovement) {
			msg.write1();
			msg << moveDestination;
		}
		else {
			msg.write0();
		}
		msg << cargoId;
		msg << isPickup;
		msg << isDropoff;
	}

	void read(Message& msg) {
		msg >> type;
		hasMovement = msg.readBit();
		if(hasMovement)
			msg >> moveDestination;
		msg >> cargoId;
		msg >> isPickup;
		msg >> isDropoff;
	}
};
