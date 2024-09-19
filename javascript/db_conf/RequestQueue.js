// queue class
export class RequestQueue {
	constructor() {
		this.queue = [];
		this.processing = false;
		this.immediateRequests = new Set();
	}
	
	enqueue(request) {
		this.queue.push(request);
		if (!this.processing) {
			this.processNext();
		}
	}
	async enqueueImmediate(request) {
		this.immediateRequests.add(request);
		try {
			// Process the immediate request right away
			await request();
			console.log('Immediate request successfully processed.');
		} catch (error) {
			console.error('Immediate request failed:', error);
		} finally {
			this.immediateRequests.delete(request);
		}
	}
	async processNext() {
		if (this.queue.length === 0) {
			this.processing = false;
			return;
		}
		this.processing = true;
		const request = this.queue.shift();
		try {
			await request();
			console.log('Request successfully processed.');
		} catch (error) {
			console.error('Request failed:', error);
		} finally {
			this.processNext();
		}
	}

	getActiveImmediateRequests() {
		return Array.from(this.immediateRequests);
	}
}