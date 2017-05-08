//
//  StateMachine.swift
//  StateMachineKit
//
//  Copyright (c) 2017 Stan Chang Khin Boon (http://lxcid.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public protocol EventType {
}

public protocol StateType {
    associatedtype Event: EventType
}

public struct Transition<State: StateType> {
    public let event: State.Event
    public let fromState: State
    public let toState: State
    
    public init(event: State.Event, fromState: State, toState: State) {
        self.event = event
        self.fromState = fromState
        self.toState = toState
    }
}


public protocol StateMachineDelegate: class {
    associatedtype State: StateType
    
    func stateMachine(_ stateMachine: StateMachine<Self>, nextStateForEvent event: State.Event, inCurrentState currentState: State) -> State?
    // FIXME: (stan@trifia.com) Should not transition in will perform transition…
    func stateMachine(_ stateMachine: StateMachine<Self>, willPerformTransition transition: Transition<State>)
    func stateMachine(_ stateMachine: StateMachine<Self>, didPerformTransition transition: Transition<State>)
}

open class StateMachine<Delegate: StateMachineDelegate> {
    open var currentState: Delegate.State
    open weak var delegate: Delegate?
    
    public init(initialState: Delegate.State) {
        self.currentState = initialState
    }
    
    open func sendEvent(_ event: Delegate.State.Event) {
        guard let nextState = self.delegate?.stateMachine(self, nextStateForEvent: event, inCurrentState: self.currentState) else {
            return
        }
        let transition = Transition(event: event, fromState: self.currentState, toState: nextState)
        self.performTransition(transition)
    }
    
    open func performTransition(_ transition: Transition<Delegate.State>) {
        self.delegate?.stateMachine(self, willPerformTransition: transition)
        self.currentState = transition.toState
        self.delegate?.stateMachine(self, didPerformTransition: transition)
    }
}
