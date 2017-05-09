<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

# Chaos

## Numerical Integration

### Euler Method

### Fourth-Order Runge-Kutta

Ref [Liz Bradley](https://www.cs.colorado.edu/~lizb/)

## Dynamics

### Flows

#### 2D

$$
\dot{\vec{x}}=\vec{F}(\vec{x})
$$

or

$$
\begin{align*}
\vec{x}&=(x,y) \\
\vec{F}&=(f,g)
\end{align*}
$$

$$
\begin{align*}
\dot{x}&=f(x,y) \\
\dot{y}&=g(x,y)
\end{align*}
$$

* stable fixed point (sink, attractor)
* unstable fixed point(source, repeller)
* saddle fixed point (mixed stability)
* limit cycle (periodic orbit; stable, unstable, or saddle cycle; try polar coordinates)

bifurcations: saddle node, pitchfork, hopf, etc.

see example [saddle-node bifurcation](https://en.wikipedia.org/wiki/Saddle-node_bifurcation):

$$
\begin{align*}
\dot{x}&=\alpha-x^2 \\
\dot{y}&=-y
\end{align*}
$$


[see nlp 3]

### Examples

#### Simple Harmonic Oscillator

$$\ddot{x}=-x$$

$$
\begin{align*}
\dot{x}&=v \\
\dot{v}&=-x
\end{align*}
$$

[see nlp 2]

$$\ddot{x}+x=0$$

$$
\begin{align*}
\dot{x}&=y \\
\dot{y}&=-x
\end{align*}
$$

[seen nlp 2, 3]

(note, need `$$` and `\begin{align}` to work)



then Damped Harmonic Oscillator...






## Reference

* [Visual Analysis of Nonlinear Dynamical Systems: Chaos, Fractals, Self-Similarity and the Limits of Prediction](http://geoffboeing.com/publications/nonlinear-chaos-fractals-prediction/)
* [Statistical Mechanics: Entropy, Order Parameters, and Complexity](http://pages.physics.cornell.edu/~sethna/StatMech/) book (PDF) and associated [Python for Education: Computational Methods for Nonlinear Systems](https://arxiv.org/abs/0704.3182)
