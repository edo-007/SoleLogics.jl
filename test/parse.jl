import SoleLogics: arity

@testset "Parsing" begin

@test_throws ErrorException parsetree("")
@test_nowarn parsetree("p")
@test_nowarn parsetree("⊤")

@test parsetree("¬p∧q") == parsetree("¬(p)∧q")
@test parsetree("¬p∧q") != parsetree("¬(p∧q)")

@test_nowarn parsebaseformula("p")

@test_nowarn ¬ parsebaseformula("p")
@test_nowarn ¬ parsetree("p")
@test_nowarn ¬ parsetree("(s∧z)", propositionallogic())
@test_nowarn ¬ parsebaseformula("p", propositionallogic())

@test_nowarn parsetree("¬p∧q∧(¬s∧¬z)", [NEGATION, CONJUNCTION])
@test_nowarn parsetree("¬p∧q∧(¬s∧¬z)", [NEGATION])
@test_nowarn parsetree("¬p∧q∧{¬s∧¬z}",
    opening_bracket="{", closing_bracket="}")
@test_nowarn parsetree("¬p∧q∧ A ¬s∧¬z    B",
    opening_bracket="A", closing_bracket="B")

@test operatorstype(
        logic(parsebaseformula("¬p∧q∧(¬s∧¬z)", [BOX]))) <: SoleLogics.BaseModalOperators
@test !(operatorstype(
    logic(parsebaseformula("¬p∧q∧(¬s∧¬z)", [BOX]))) <: SoleLogics.BasePropositionalOperators)
@test !(operatorstype(logic(
    parsebaseformula("¬p∧q∧(¬s∧¬z)", modallogic()))) <: SoleLogics.BasePropositionalOperators)
@test (@test_nowarn operatorstype(
    logic(parsebaseformula("¬p∧q∧(¬s∧¬z)"))) <: SoleLogics.BasePropositionalOperators)

@test_nowarn parsetree("¬p∧q→(¬s∧¬z)")

@test syntaxstring(parsetree("⟨G⟩p")) == "⟨G⟩(p)"
@test syntaxstring(parsetree("[G]p")) == "[G](p)"

@test_nowarn parsetree("⟨G⟩p")

@test alphabet(logic(parsebaseformula("p→q"))) == AlphabetOfAny{String}()


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ function notation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@test syntaxstring(parsetree("p∧q"); function_notation = true) == "∧(p, q)"
@test syntaxstring(parsetree("p→q"); function_notation = true) == "→(p, q)"

@test filter(!isspace, syntaxstring(parsetree("¬p∧q∧(¬s∧¬z)");
    function_notation = true)) == "∧(¬(p),∧(q,∧(¬(s),¬(z))))"

@test_nowarn parsetree("→(∧(¬p, q), ∧(¬s, ¬z))", function_notation=true)
@test_nowarn parsetree("→(∧(¬p; q); ∧(¬s; ¬z))",
    function_notation=true, arg_delim = ";")
@test_nowarn parsetree("→{∧{¬p; q}; ∧{¬s; ¬z}}", function_notation=true,
    opening_bracket = "{", closing_bracket = "}",
    arg_delim = ";")


@test filter(!isspace, syntaxstring(parsetree("¬p∧q→(¬s∧¬z)");
    function_notation = true)) == "→(∧(¬(p),q),∧(¬(s),¬(z)))"
@test filter(!isspace, syntaxstring(
    parsetree("¬p∧q→A¬s∧¬zB",
        opening_bracket = "A",
        closing_bracket = "B");
    function_notation = true)) == "→(∧(¬(p),q),∧(¬(s),¬(z)))"
@test_nowarn parsetree("¬p∧q→     (¬s∧¬z)")
@test parsetree("□p∧   q∧(□s∧◊z)", [BOX]) == parsetree("□p∧   q∧(□s∧◊z)")
@test syntaxstring(parsetree("◊ ◊ ◊ ◊ p∧q"); function_notation = true) ==
    "∧(◊(◊(◊(◊(p)))), q)"
@test syntaxstring(parsetree("¬¬¬ □□□ ◊◊◊ p ∧ ¬¬¬ q"); function_notation = true) ==
    "∧(¬(¬(¬(□(□(□(◊(◊(◊(p))))))))), ¬(¬(¬(q))))"

f = parsetree("¬((¬(⟨G⟩(q))) → (([G](p)) ∧ ([G](q))))")
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)
f = parsetree("((¬(q ∧ q)) ∧ ((p ∧ p) ∧ (q → q))) → ([G]([G](⟨G⟩(p))))")
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)
f = parsetree("((⟨G⟩(⟨G⟩(q))) ∧ (¬([G](p)))) → (((q → p) → (¬(q))) ∧ (¬([G](q))))")
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)
f = parsetree("[G](¬(⟨G⟩(p ∧ q)))")
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)

f = parsetree("⟨G⟩(((¬(⟨G⟩((q ∧ p) → (¬(q))))) ∧ (((¬(q → q)) → ((q → p) → (¬(q))))"*
    "∧ (((¬(p)) ∧ (⟨G⟩(p))) → (¬(⟨G⟩(q)))))) ∧ ((¬(([G](p ∧ q)) → (¬(p → q)))) →" *
    "([G](([G](q∧ q)) ∧ ([G](q → p))))))")
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ malformed input ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@test_throws ErrorException parsetree("")
@test_throws ErrorException parsetree("¬p◊")
@test_throws ErrorException parsetree("¬p◊q")
@test_throws ErrorException parsetree("◊¬p◊")
@test_throws ErrorException parsetree("◊¬p◊q")
@test_throws ErrorException parsetree("(p∧q", [NEGATION, CONJUNCTION])
@test_throws ErrorException parsetree("))))", [CONJUNCTION])
@test_throws ErrorException parsetree("⟨G⟩p ¬⟨G⟩q")
@test_throws ErrorException parsetree("¬[[G]]p")

@test_throws ErrorException parsetree(""; function_notation = true)
@test_throws ErrorException parsetree("¬p◊"; function_notation = true)
@test_throws ErrorException parsetree("¬p◊q"; function_notation = true)
@test_throws ErrorException parsetree("◊¬p◊"; function_notation = true)
@test_throws ErrorException parsetree("◊¬p◊q"; function_notation = true)
@test_throws ErrorException parsetree("(p∧q", [NEGATION, CONJUNCTION];
    function_notation = true)
@test_throws ErrorException parsetree("))))", [CONJUNCTION];
    function_notation = true)
@test_throws ErrorException parsetree("¬[[G]]p"; function_notation = true)

@test_throws ErrorException parsetree("¬p∧q∧(¬s∧¬z)", opening_bracket="{")
@test_throws ErrorException parsetree("¬p∧q∧{¬s∧¬z)",
    opening_bracket="{", closing_bracket="}")
@test_throws ErrorException parsetree("¬p∧q∧ C ¬s∧¬z    B",
    opening_bracket="A", closing_bracket="B")

@test_throws ErrorException parsetree("¬p∧q→ |¬s∧¬z|",
    opening_bracket = "|", closing_bracket = "|")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ parsing propositions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@test_nowarn parsetree("¬1→0";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))))
@test_nowarn parsetree("¬0.42∧1";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))))
@test_nowarn parsetree("¬-96";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))))

@test_nowarn parsetree("→(¬1,0)";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))),
    function_notation = true)
@test_nowarn parsetree("→(¬1;0)";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))),
    function_notation = true, arg_delim = ";")
@test_nowarn parsetree("→(¬1/0)";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))),
    function_notation = true, arg_delim = "/")
@test_nowarn parsetree("∧(¬0.42,1)";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))),
    function_notation = true)
@test_nowarn parsetree("¬-96";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))),
    function_notation = true)

@test_throws ErrorException parsetree("[G][G]-1.2[G]";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))))
@test_throws ErrorException parsetree("¬-3(";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))))

@test_throws ArgumentError parsetree("p";
    proposition_parser = (x -> Proposition{Float64}(parse(Float64, x))))

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ custom operator ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TERNOP = SoleLogics.NamedOperator{:⇶}()
SoleLogics.arity(::Type{typeof(TERNOP)}) = 3

QUATERNOP = SoleLogics.NamedOperator{:⩰}()
SoleLogics.arity(::Type{typeof(QUATERNOP)}) = 4

@test_nowarn parsetree("⇶(p, q, r)", [TERNOP]; function_notation=true)
@test_nowarn parsetree("⇶(p1, q1, ⇶(p2, q2, r2))", [TERNOP]; function_notation=true)

@test_nowarn parsetree("⩰(p, q, r, s)", [QUATERNOP]; function_notation=true)
@test_nowarn parsetree("⩰(p1, q1, r1, ⩰(p2, q2, r2, s2))",
    [QUATERNOP]; function_notation=true)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ custom relation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

struct _TestRel <: AbstractRelation end;
testrel  = _TestRel();
SoleLogics.arity(::Type{_TestRel}) = 2
SoleLogics.syntaxstring(::Type{_TestRel}; kwargs...) = "Test,Relation"

# If AbstractRelationalOperator interface changes, just redefine the following:
struct SoleRelationalOperator{R<:AbstractRelation} <: AbstractRelationalOperator{R} end
(SoleRelationalOperator)(r::AbstractRelation) = SoleRelationalOperator{typeof(r)}()
SoleLogics.syntaxstring(op::SoleRelationalOperator; kwargs...) =
    "🌅$(syntaxstring(relationtype(op);  kwargs...))🌄"

struct PipeRelationalOperator{R<:AbstractRelation} <: AbstractRelationalOperator{R} end
(PipeRelationalOperator)(r::AbstractRelation) = PipeRelationalOperator{typeof(r)}()
SoleLogics.syntaxstring(op::PipeRelationalOperator; kwargs...) =
    "|$(syntaxstring(relationtype(op);  kwargs...))|"

struct CurlyRelationalOperator{R<:AbstractRelation} <: AbstractRelationalOperator{R} end
(CurlyRelationalOperator)(r::AbstractRelation) = CurlyRelationalOperator{typeof(r)}()
SoleLogics.syntaxstring(op::CurlyRelationalOperator; kwargs...) =
    "{$(syntaxstring(relationtype(op);  kwargs...))}"

struct MyCustomRelationalOperator{R<:AbstractRelation} <: AbstractRelationalOperator{R} end
(MyCustomRelationalOperator)(r::AbstractRelation) = MyCustomRelationalOperator{typeof(r)}()
SoleLogics.syntaxstring(op::MyCustomRelationalOperator; kwargs...) =
    "LEFT CUSTOM BRACKET $(syntaxstring(relationtype(op);  kwargs...)) RIGHT CUSTOM BRACKET"
f = parsetree("LEFT CUSTOM BRACKET G RIGHT CUSTOM BRACKET p ∧ ¬" *
    "LEFT CUSTOM BRACKET G RIGHT CUSTOM BRACKET q", [MyCustomRelationalOperator(globalrel)])

@test_nowarn parsetree("🌅G🌄p ∧ ¬🌅G🌄q", [SoleRelationalOperator(globalrel)])
@test_nowarn parsetree("∧(🌅G🌄p,¬🌅G🌄q)", [SoleRelationalOperator(globalrel)];
    function_notation = true)
@test_nowarn parsetree("∧[🌅G🌄p DELIM ¬🌅G🌄q)", [SoleRelationalOperator(globalrel)];
    function_notation = true, opening_bracket = "[", arg_delim = "DELIM")

@test_nowarn parsetree("|G|p   ∧ ¬|G|q", [PipeRelationalOperator(globalrel)])
@test_nowarn parsetree("∧(|G|p,  ¬|G|q)", [PipeRelationalOperator(globalrel)];
    function_notation = true)

@test_nowarn parsetree("{G}p   ∧  ¬{G}q", [CurlyRelationalOperator(globalrel)])
@test_nowarn parsetree("∧({G}p   ,¬{G}q)", [CurlyRelationalOperator(globalrel)];
    function_notation = true)

_f = parsetree("|G|p ∧ ¬{G}q", [CurlyRelationalOperator(globalrel)])
@test syntaxstring(token(children(_f)[1])) == "|G|p" # PipeRelationalOperator not specified
_f = parsetree("∧(|G|p,¬{G}q)", [CurlyRelationalOperator(globalrel)];
    function_notation = true)
@test syntaxstring(token(children(_f)[1])) == "|G|p"

_f = parsetree("{Gp ∧ ¬{G}q", [CurlyRelationalOperator(globalrel)])
@test syntaxstring(token(children(_f)[1])) == "{Gp"

@test_nowarn parsetree("¬⟨Test,Relation⟩[Test,Relation]p",
    [BoxRelationalOperator(testrel), DiamondRelationalOperator(testrel)]
)
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ parsebaseformula ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

@test_throws ErrorException parsebaseformula("")
@test_nowarn parsebaseformula("⊤")
@test_nowarn parsebaseformula("⊤ ∧ ⊤")
@test_nowarn parsebaseformula("⊤ ∧ p")
@test_nowarn parsebaseformula("⊥ ∧ □¬((p∧¬q)→r)")
@test_nowarn parsebaseformula("□¬((p∧¬q)→r) ∧ ⊤")
@test_nowarn parsebaseformula("⊤ ∧ (⊥∧¬⊤→⊤)")

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ stress tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

s = "¬((¬(([G](⟨G⟩(¬((¬([G](⟨G⟩(⟨G⟩(q))))) → (¬(⟨G⟩((¬(q)) ∧ ([G](p))))))))) ∧ (⟨G⟩((" *
    "[G](⟨G⟩([G](⟨G⟩(⟨G⟩(q ∧ q)))))) ∧ (¬(⟨G⟩((([G](⟨G⟩(p))) ∧ (⟨G⟩(⟨G⟩(p)))) ∧ (⟨G⟩(" *
    "[G](p → p)))))))))) ∧ (([G](([G]([G](¬((((¬(p)) → (⟨G⟩(q))) → ((⟨G⟩(p)) → (q → p" *
    "))) ∧ (⟨G⟩(¬([G](p)))))))) ∧ ([G](⟨G⟩([G](¬([G]([G](q ∧ p))))))))) ∧ (¬([G]((⟨G⟩" *
    "(⟨G⟩(¬(((⟨G⟩(q)) ∧ (⟨G⟩(q))) → (⟨G⟩(q → p)))))) ∧ ([G](¬(((¬(¬(q))) → (¬(q → p))" *
    ") ∧ (([G](p → p)) → ((⟨G⟩(p)) → (q → p)))))))))))"
f = parsetree(s)
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)

s = "◊((¬((◊(◊(((¬(¬(q))) ∧ ((p ∧ p) ∨ (¬(p)))) → (¬(□(¬(q))))))) ∨ ((□(((□(◊(q))) →"  *
    "((p → q) ∨ (□(q)))) → (◊(□(◊(p)))))) ∨ ((((□(q ∨ p)) → (◊(¬(q)))) → (((p ∨ q) →"  *
    "(◊(q))) ∧ ((q ∨ p) ∧ (◊(q))))) ∧ ((¬((◊(p)) ∨ (¬(p)))) ∧ (□(◊(q ∧ p)))))))) → ((" *
    "◊(¬((□((◊(q → q)) ∨ (□(□(p))))) ∧ (¬((¬(◊(p))) ∨ ((◊(q)) ∨ (□(q)))))))) → ((¬((¬" *
    "(◊((q ∨ q) ∨ (□(q))))) → (((¬(□(q))) ∨ (□(◊(q)))) → (((◊(p)) ∧ (◊(q))) ∨ (¬(q ∧"  *
    "q)))))) → ((□(◊(¬(◊(¬(p)))))) ∨ ((□(□((q → p) ∧ (p ∧ p)))) ∨ (((◊(◊(p))) → ((p →" *
    "q) ∧ (p → q))) ∧ (□((p ∨ q) ∧ (◊(q))))))))))"
f = parsetree(s)
@test syntaxstring(f) == syntaxstring(parsetree(syntaxstring(f)))
@test syntaxstring(f; function_notation = true) ==
    syntaxstring(parsetree(syntaxstring(f)); function_notation = true)
