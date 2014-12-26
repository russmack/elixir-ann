defmodule BooleanLogic.Or do
    @moduledoc """
    Neural network training of a Boolean logic Or.
    """

    # Constants
    @rate 0.2  # Weight adjustment rate.
    @threshold 98 # Threshold required for neuron to fire.
    @epoch_max 10  # For limiting the number of iterations, eg while experimenting.


    def main() do
        weights = init_weights(2)
        training_set = get_training_data()
        
        epoch_state = %{id: 0, epoch_results: []}
        run_training(@epoch_max, training_set, weights, 0, epoch_state)
    end

    def run_training(epoch_max, _training_set, weights, epoch_success, %{id: id, epoch_results: epoch_results}) when id >= epoch_max do
        {epoch_success, weights, %{id: id, epoch_results: epoch_results}}
    end
    def run_training(_epoch_max, _training_set, weights, epoch_success, %{id: id, epoch_results: epoch_results}) when epoch_success >= @threshold do
        epoch_state = %{id: id, epoch_results: epoch_results}
        {epoch_success, weights, epoch_state}
    end
    def run_training(epoch_max, training_set, weights, _epoch_success, %{id: id, epoch_results: epoch_results}) do
        epoch_state = %{id: id, epoch_results: epoch_results}
        {epoch_success, weights, epoch_state} = run_epoch(training_set, weights, epoch_state)
        run_training(epoch_max, training_set, weights, epoch_success, epoch_state)
    end

    def run_epoch(training_set, weights, epoch_state) do
        epoch_count = epoch_state[:id] + 1
        display_epoch_header(epoch_count)
        epoch_results = epoch_state[:epoch_results]

        {weights, epoch_results} = Enum.reduce(training_set, {weights, epoch_results}, fn(test, {weights, epoch_results}) -> 
            run_tests(test, {weights, epoch_results})
        end)
        
        epoch_success = (Enum.sum(epoch_results) / Enum.count(epoch_results)) * 100
        
        display_epoch_footer(epoch_count, epoch_success)
        epoch_state = %{id: epoch_count, epoch_results: []}  # Clear epoch results.
        {epoch_success, weights, epoch_state}
    end

    def run_tests(test, {weights, epoch_results}) do
        display_test_header(weights)

        test_inputs = test_get_inputs(test)
        test_answer = test_get_answer(test)
        
        neuron_output = neuron_activation_function(test_inputs, weights)
        {is_activated, epoch_results} = is_output_correct(test_answer, neuron_output, epoch_results)
        if is_activated == false do
            weights = update_weight(test_answer, 0, weights, neuron_output, @rate)
            weights = update_weight(test_answer, 1, weights, neuron_output, @rate)
        end
        display_test_footer(test_inputs, neuron_output, is_activated)
        {weights, epoch_results}
    end
    
    def update_weight(test_answer, input, weights, neuron_output, rate) do
        new_weight = Enum.at(weights, input) + (rate * (test_answer - neuron_output))
        List.replace_at(weights, input, new_weight)
    end

    def neuron_activation_function(inputs, weights) do  # Perceptron
        sum = Enum.at(inputs, 0) * Enum.at(weights, 0) + Enum.at(inputs, 1) * Enum.at(weights, 1)
        threshold = 2
        if (sum > threshold) do
            1.0
        else
            0.0
        end
    end

    def is_output_correct(test_answer, neuron_output, epoch_results) when test_answer == neuron_output do
        {true, List.insert_at(epoch_results, Enum.count(epoch_results), 1)}
    end
    def is_output_correct(_, _, epoch_results) do
        {false, List.insert_at(epoch_results, Enum.count(epoch_results), 0)}
    end

    def test_get_answer(test) do
        List.first tl test
    end

    def test_get_inputs(test) do
        hd test
    end

    def random() do
        << a :: 32, b :: 32, c :: 32 >> = :crypto.rand_bytes(12)
        :random.seed(a, b, c)
        Float.round(:random.uniform, 2)
    end

    def init_weights(max), do: fill_weights(max, 0, [])
    def fill_weights(max, counter, weights) when counter >= max, do: weights
    def fill_weights(max, counter, weights) do
            size = length(weights)
            rnd_weight = random()
            weights = List.insert_at(weights, size, rnd_weight)
            fill_weights(max, counter+1, weights)
    end


    def get_training_data() do
        [
            [ [ 0.0, 0.0 ], 0.0 ], 
            [ [ 0.0, 1.0 ], 1.0 ], 
            [ [ 1.0, 0.0 ], 1.0 ], 
            [ [ 1.0, 1.0 ], 1.0 ]
        ]
    end

    def display_epoch_header(epoch_count) do
        IO.puts ""
        IO.puts "##### Epoch #{epoch_count} #####"
        IO.puts "-----------------------------------------------"
    end

    def display_epoch_footer(epoch_count, epoch_success) do
        IO.puts "##### Epoch #{inspect epoch_count} : #{inspect epoch_success} #####"
        IO.puts "-----------------------------------------------"
    end

    def display_test_header(weights) do
        IO.puts "Weights: #{inspect weights}"
    end

    def display_test_footer(test_inputs, neuron_output, is_activated) do
        IO.puts " #{inspect Enum.at(test_inputs, 0)}, #{inspect Enum.at(test_inputs, 1)} gave #{inspect neuron_output} : #{inspect is_activated}"
        IO.puts "-----------------------------------------------"
    end
end
